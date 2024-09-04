import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import { firestore } from "firebase-admin";
import {
  SampleModel,
  createExcelSheetWithDeletedSamples,
  createSampleExcelSheetAndSendEmail,
  createSampleExcelSheetFromList,
} from "./sample_pdf_generation";
import { onCall } from "firebase-functions/v1/https";
import axios from "axios";
const cors = require("cors")({ origin: true });
const crypto = require("crypto");

var serviceAccount = require("./serviceAccountKey.json");
const firebaseAdmin = admin.initializeApp({
  credential: admin.credential.cert(serviceAccount as admin.ServiceAccount),
});

let runtimeOpts: functions.RuntimeOptions = {
  vpcConnector: "agrokcloudfunctions",
  vpcConnectorEgressSettings: "ALL_TRAFFIC",
};

export const userEmailChange = functions.firestore
  .document("users/{userId}")
  .onWrite(async (change, context) => {
    var beforeData = change.before.data();
    var afterData = change.after.data();
    if (
      beforeData?.email != afterData?.email &&
      afterData?.email != undefined
    ) {
      var userId = context.params.userId;
      var afterEmail = afterData?.email;
      await firebaseAdmin
        .auth()
        .updateUser(userId, { email: afterEmail, emailVerified: false });
      firestore()
        .collection("users")
        .doc(userId)
        .update({ isConfirmed: false });
    }
  });

export const inviteNotification = functions.firestore
  .document("invites/{inviteId}")
  .onCreate(async (snapshot, context) => {
    var data = snapshot.data();
    var inviteEmail = data.email;
    if (inviteEmail == undefined) return;
    var userQueryDocs = (
      await firestore()
        .collection("users")
        .where("email", "==", inviteEmail)
        .get()
    ).docs;
    if (userQueryDocs.length == 0) return;
    var userData = userQueryDocs[0].data();
    if (userData == null) return;
    var userId = userData.id;
    if (userId == null) return;
    var companyData = (
      await (data.invitedTo as firestore.DocumentReference).get()
    ).data();
    if (companyData == null) return;
    var notification = {
      title: `Join ${companyData.name}`,
      description: `${userData.firstName} ${userData.lastName} invited you to join ${companyData.name}`,
    };
    await firestore()
      .collection("users")
      .doc(userId)
      .update({
        notifications: firestore.FieldValue.arrayUnion(notification),
      });
  });

export const deleteExpiredInvites = functions.pubsub
  .schedule("every 24 hours")
  .onRun(async (context) => {
    var inviteDocs = (await firestore().collection("invites").get()).docs;
    var currentDate = Date.now();
    await Promise.all(
      inviteDocs.map(async (inviteDoc) => {
        var invite = inviteDoc.data();
        if (invite == null) return;
        var inviteCreatedDate: Date = invite.created.toDate();
        if (
          (currentDate - inviteCreatedDate.getTime()) / (1000 * 3600 * 24) >
          30
        ) {
          var inviteId = inviteDoc.ref.id;
          await inviteDoc.ref.delete();
          var companyReference: firestore.DocumentReference = invite.invitedTo;
          var body = new Map<String, Object>();
          body.set(
            `invitedUsers.${inviteId}`,
            admin.firestore.FieldValue.delete()
          );
          await companyReference.update(Object.fromEntries(body));
        }
      })
    );
    //see invite list, check day difference
    //if yes, delete that invite, go to company and delete that invite too
  });

exports.updateCompanyAdminUserInfo = functions.firestore
  .document("companies/{companyId}")
  .onCreate(async (snapshot, context) => {
    const companyData = snapshot.data();
    if (companyData.companyAdminUserInfo != undefined) return;
    const users = companyData?.users;
    if (users == undefined || users.length == 0) return;
    const userReference = users[0];
    const userData = (await userReference.get()).data();
    if (userData == undefined) return;
    const fullName = userData.firstName + " " + userData.lastName;
    const email = userData.email;
    await snapshot.ref.update({
      companyAdminUserInfo: {
        fullName: fullName,
        email: email,
        userReference: userReference,
      },
    });
  });

exports.updateCompanyName = functions.firestore
  .document("companies/{companyId}")
  .onUpdate(async (change, context) => {
    const companyId = context.params.companyId;
    const oldName = change.before.data().name;
    const newName = change.after.data().name;

    if (oldName === newName) {
      console.log("Name hasn't changed. Skipping update.");
      return;
    }

    const itemRef = admin
      .firestore()
      .collection("global_barcodes")
      .where(
        "companyReference",
        "==",
        admin.firestore().doc(`companies/${companyId}`)
      );
    await itemRef.get().then((querySnapshot) => {
      const batch = admin.firestore().batch();
      querySnapshot.forEach((doc) => {
        batch.update(doc.ref, { companyName: newName });
      });
      return batch.commit();
    }); //update global barcodes

    //update sample doc, companyName property
    const sampleRef = admin
      .firestore()
      .collection("samples")
      .where(
        "companyReference",
        "==",
        admin.firestore().doc(`companies/${companyId}`)
      );
    await sampleRef.get().then((querySnapshot) => {
      const batch = admin.firestore().batch();
      querySnapshot.forEach((doc) => {
        batch.update(doc.ref, { companyName: newName });
      });
      return batch.commit();
    });

    //update users doc, where companyReferences array of objects has a an item where companyReference.id == companyId
    const companyUsers = (
      await admin.firestore().doc(`companies/${companyId}`).get()
    ).data()!["users"] as firestore.DocumentReference[];
    await Promise.all(
      companyUsers.map(async (user) => {
        const userDoc = await user.get();
        const userCompanyReferences = userDoc.data()!["companyReferences"] as {
          companyReference: firestore.DocumentReference;
          companyName: string;
          isAdmin: boolean;
        }[];
        var indexToEdit = userCompanyReferences.findIndex(
          (company) => company.companyReference.id == companyId
        );
        if (indexToEdit != -1) {
          userCompanyReferences[indexToEdit].companyName = newName;
          await userDoc.ref.update({
            companyReferences: userCompanyReferences,
          });
        }
      })
    );
  });

exports.updateSampleFarmName = functions.firestore
  .document("samples/{sampleId}")
  .onCreate(async (snapshot, context) => {
    const sampleData = snapshot.data();
    const companyReference = sampleData?.companyReference;
    if (companyReference == undefined) return;
    const companyData = (await companyReference.get()).data();
    if (companyData == undefined) return;
    const companyName = companyData.name;
    await snapshot.ref.update({ companyName: companyName });
  });

exports.addEnabledProperty = functions.firestore
  .document("users/{userId}")
  .onCreate(async (snapshot, context) => {
    await snapshot.ref.update({ enabled: true });
  });

//cloud functions that listens to changes in companys collection, check if barcodesAssigned, barcodesPurchased or usedBarcodesCount changed, if barcodesAssigned or barcodesPurchased changed, update admin info doc field "assignedBarcodesAmount" with the difference of the sum of barcodesAssigned and barcodesPurchased (new value - old value), if usedBarcodesCount changed, update admin info doc field "usedBarcodesAmount" with the difference of usedBarcodesCount (new value - old value)
exports.updateAdminInfo = functions.firestore
  .document("companies/{companyId}")
  .onUpdate(async (change, context) => {
    //calculate barcode count differences
    const oldBarcodesAssigned = change.before.data().barcodesAssigned;
    const newBarcodesAssigned = change.after.data().barcodesAssigned;
    const oldBarcodesPurchased = change.before.data().barcodesPurchased;
    const newBarcodesPurchased = change.after.data().barcodesPurchased;
    const oldUsedBarcodesCount = change.before.data().usedBarcodesCount;
    const newUsedBarcodesCount = change.after.data().usedBarcodesCount;
    if (
      !(
        oldBarcodesAssigned === newBarcodesAssigned &&
        oldBarcodesPurchased === newBarcodesPurchased &&
        oldUsedBarcodesCount === newUsedBarcodesCount
      )
    ) {
      const oldBarcodesAssignedAmount =
        oldBarcodesAssigned + oldBarcodesPurchased;
      const newBarcodesAssignedAmount =
        newBarcodesAssigned + newBarcodesPurchased;
      const differenceBarcodesAssigned =
        newBarcodesAssignedAmount - oldBarcodesAssignedAmount;
      const differenceUsedBarcodes =
        newUsedBarcodesCount - oldUsedBarcodesCount;
      const adminInfoRef = admin.firestore().collection("admin").doc("info");
      await adminInfoRef.get().then((doc) => {
        if (doc.exists) {
          adminInfoRef.update({
            assignedBarcodesAmount: admin.firestore.FieldValue.increment(
              differenceBarcodesAssigned
            ),
            usedBarcodesAmount: admin.firestore.FieldValue.increment(
              differenceUsedBarcodes
            ),
          });
        }
      });
    } else {
    }
  });

exports.sendYesterdaySamples = functions.pubsub
  .schedule("0 0 * * *")
  .onRun(async (context) => {
    await createSampleExcelSheetAndSendEmail(firebaseAdmin);
  });

// createSampleExcelSheetAndSendEmail(firebaseAdmin);

// async function deleteAllEmails() {
//   const snapshot = await admin.firestore().collection("mail").get();
//   snapshot.forEach((doc) => {
//     doc.ref.delete();
//   });
//   console.log("done");
// }

export const createSamplesReport = onCall(async (data) => {
  var body = data["samples"].map((item: any) => {
    var sampleDateMilliseconds = item["sampleDate"] as number | undefined;
    var createdDateMilliseconds = item["createdDate"] as number;
    var sampleDate: firestore.Timestamp | undefined;
    if (sampleDateMilliseconds != undefined) {
      sampleDate = firestore.Timestamp.fromMillis(sampleDateMilliseconds);
    }
    var createdDate = firestore.Timestamp.fromMillis(createdDateMilliseconds);
    if (sampleDate != undefined) {
      item["sampleDate"] = sampleDate;
    }
    item["createdDate"] = createdDate;
    return item;
  }) as SampleModel[];
  var signedUrl = await createSampleExcelSheetFromList(firebaseAdmin, body);
  return signedUrl;
});

export const deleteFlaggedSamplesAndCreateReport = functions.pubsub
  .schedule("0 0 5 * *")
  .onRun(async (context) => {
    await subDeleteFlaggedSamplesAndCreateReport();
  });

export const subDeleteFlaggedSamplesAndCreateReport = async () => {
  var deletedDocs = firestore()
    .collection("samples")
    .where("deleted", "==", true)
    .get();
  var currentDate = new Date();
  var deletedDocsData = (await deletedDocs).docs
    .map((item) => item.data())
    .filter(
      (item) =>
        item.deletedAt != null &&
        (item.deletedAt as firestore.Timestamp).toDate() <
          new Date(currentDate.getFullYear(), currentDate.getMonth(), 1)
    );
  var deletedSampleIds: string[] = [];
  await Promise.all(
    deletedDocsData.map(async (item) => {
      var sampleId = item.id;
      await firestore().collection("samples").doc(sampleId).delete();
      deletedSampleIds.push(sampleId);
    })
  );
  await createExcelSheetWithDeletedSamples(firebaseAdmin, deletedSampleIds);
  console.log("todo ok");
};

function calculateTotalPrice(quantity: number, shipping: boolean): string {
  let pricePerItem: number;

  if (shipping) {
    // Higher shipping charges
    if (quantity >= 0 && quantity < 10) {
      pricePerItem = 52.5;
    } else if (quantity >= 10 && quantity < 20) {
      pricePerItem = 45.0;
    } else if (quantity >= 20 && quantity < 50) {
      pricePerItem = 40.0;
    } else if (quantity >= 50 && quantity < 100) {
      pricePerItem = 37.5;
    } else if (quantity >= 100 && quantity < 250) {
      pricePerItem = 35.0;
    } else if (quantity >= 250 && quantity < 1000) {
      pricePerItem = 32.5;
    } else if (quantity >= 1000) {
      pricePerItem = 30.0;
    } else {
      return '0.00';
    }
  } else {
    // Lower shipping charges
    if (quantity >= 0 && quantity < 10) {
      pricePerItem = 40.0;
    } else if (quantity >= 10 && quantity < 20) {
      pricePerItem = 37.5;
    } else if (quantity >= 20 && quantity < 50) {
      pricePerItem = 35.0;
    } else if (quantity >= 50 && quantity < 100) {
      pricePerItem = 32.5;
    } else if (quantity >= 100 && quantity < 250) {
      pricePerItem = 30.0;
    } else if (quantity >= 250 && quantity < 1000) {
      pricePerItem = 27.5;
    } else if (quantity >= 1000) {
      pricePerItem = 25.0;
    } else {
      return '0.00';
    }
  }

  const totalPrice = quantity * pricePerItem;
  return totalPrice.toFixed(2);
}

const merchantID = "623370"; // Converge Account ID
const merchantUserID = "apiuser842932"; // Converge User ID
const merchantPinCode =
  "PJRKCV7V7LH9JPAT80VXAVYOI00KRQLDS1UTUOZ3828Z49WEVTARAN57KS53LT9Z"; // Converge PIN

export const payWithToken = functions
  .runWith(runtimeOpts)
  .https.onRequest(async (req, res) => {
    cors(req, res, async () => {
      console.log(`debugging payWithToken 1`);
      const token = req.body.token;
      const amount = req.body.amount;
      const companyId = req.body.companyId;
      const shipping = req.body.shipping === 'true';
      const price = calculateTotalPrice(Number(amount), shipping);
      const invoiceNumber = `${Date.now()}${(
        Math.floor(Math.random() * 10000) + 1
      ).toString()}`;
      const url = "https://api.convergepay.com/VirtualMerchant/processxml.do";
      console.log(`debugging payWithToken 2`);
      try {
        const encryptedData = req.body.verificationToken; // Assuming the encrypted data is sent in the request body
        const decryptedJson = decrypt(fromUrlSafeBase64(encryptedData));
        console.log(`debugging payWithToken 3`);
        if (
          decryptedJson == null ||
          decryptedJson == undefined ||
          decryptedJson.company_id != companyId ||
          decryptedJson.amount != req.body.amount
        ) {
          console.log(`debugging payWithToken 4`);
          res.status(500).send("Error in decryption");
          return;
        }
      } catch (error) {
        console.log(`debugging payWithToken 5`);
        console.error("Decryption or JSON parsing error:", error);
        res.status(500).send("Error in decryption or JSON parsing");
        return;
      }
      var adminInfoDoc = await firestore()
        .collection("admin")
        .doc("info")
        .get();
      var assignableBarcodes = adminInfoDoc.data()![
        "assignableBarcodes"
      ] as string[];
      if (assignableBarcodes.length < amount) {
        res.status(500).send("Not enough barcodes to assign");
        return;
      }

      var xmlRequest = `xmldata=
  <txn>
      <ssl_merchant_id>${merchantID}</ssl_merchant_id>
      <ssl_user_id>${merchantUserID}</ssl_user_id>
      <ssl_pin>${merchantPinCode}</ssl_pin>
      <ssl_transaction_type>ccsale</ssl_transaction_type>
      <ssl_token>${token}</ssl_token>
      <ssl_amount>${price}</ssl_amount>
      <ssl_vendor_id>sc900410</ssl_vendor_id>
      <ssl_invoice_number>${invoiceNumber}</ssl_invoice_number>
      <ssl_merchant_initiated_unscheduled>Y</ssl_merchant_initiated_unscheduled>
  </txn>`;
      console.log(`debugging payWithToken 6`);
      axios
        .post(url, xmlRequest, {
          headers: { "Content-Type": "application/x-www-form-urlencoded" },
        })
        .then((response) => {
          console.log(`debugging payWithToken 7`);
          console.log(`response data is ${response.data}`);
          res.status(200).send(response.data);
        })
        .catch((error) => {
          console.log(`debugging payWithToken 8`);
          console.error(`error.message is ${error.message}`);
          // Handle error here
          res.status(500).send(`error ad ${error.message}`);
        });
    });
  });

export const getConvergePayToken = functions
  .runWith(runtimeOpts)
  .https.onRequest(async (req, res) => {
    cors(req, res, async () => {
      if (req.method === "POST") {
        const url =
          "https://api.convergepay.com/hosted-payments/transaction_token"; // Converge URL
        const amount = req.body.amount;
        const shipping = req.body.shipping === 'true';
        const price = calculateTotalPrice(Number(amount), shipping);
        const address = req.body.address;
        const zip = req.body.zip;
        const email = req.body.email;
        const isAdmin = req.body.is_admin;
        const companyId = req.body.companyId;
        const saveCard = req.body.save_card;
        const invoiceNumber = `${Date.now()}${(
          Math.floor(Math.random() * 10000) + 1
        ).toString()}`;

        try {
          const encryptedData = req.body.verificationToken; // Assuming the encrypted data is sent in the request body
          console.log(`encryptedData ${encryptedData}`);
          const decryptedJson = decrypt(fromUrlSafeBase64(encryptedData));
          if (
            decryptedJson == null ||
            decryptedJson == undefined ||
            decryptedJson.company_id != companyId ||
            decryptedJson.amount != req.body.amount
          ) {
            res.status(500).send("Error in decryption");
            return;
          }
        } catch (error) {
          console.error("Decryption or JSON parsing error:", error);
          res.status(500).send("Error in decryption or JSON parsing");
          return;
        }

        var adminInfoDoc = await firestore()
          .collection("admin")
          .doc("info")
          .get();
        var assignableBarcodes = adminInfoDoc.data()![
          "assignableBarcodes"
        ] as string[];
        if (assignableBarcodes.length < amount) {
          res.status(500).send("Not enough barcodes to assign");
          return;
        }

        try {
          console.log(`res.body ${req.body}`);
        } catch (e) {
          console.log(`resbody error ${e}`);
        }
        try {
          console.log(`res.body parsed ${JSON.parse(req.body)}`);
        } catch (e) {
          console.log(`resbody parsed error ${e}`);
        }
        try {
          console.log(`res.body amount key ${req.body["amount"]}`);
        } catch (e) {
          console.log(`resbody amount key error ${e}`);
        }
        try {
          console.log(`res.body amount prop ${req.body.amount}`);
        } catch (e) {
          console.log(`resbody amount prop error ${e}`);
        }
        try {
          console.log(`res.body amount prop ${req.body.isAdmin}`);
        } catch (e) {
          console.log(`resbody amount prop error ${e}`);
        }
        try {
          console.log(`res.body amount prop ${req.body.card_token}`);
        } catch (e) {
          console.log(`resbody amount prop error ${e}`);
        }

        // Set up POST request data
        console.log("debug label 1");
        const postData = {
          ssl_account_id: merchantID,
          ssl_user_id: merchantUserID,
          ssl_pin: merchantPinCode,
          ssl_transaction_type: "CCSALE",
          ssl_amount: price,
          ssl_email: email,
          ssl_vendor_id: "sc900410",
          ssl_avs_zip: zip,
          ssl_invoice_number: invoiceNumber,
          ssl_avs_address: address,
        } as any;
        console.log("debug label 2");
        postData.ssl_merchant_initiated_unscheduled = "Y";
        console.log("debug label 3");
        if (isAdmin == "1" && saveCard == "1") {
          postData.ssl_add_token = "Y";
          postData.ssl_get_token = "Y";
        }
        console.log("debug label 4");
        console.log(`postData ${JSON.stringify(postData, null, 2)}`);

        // Use Axios to make the POST request
        axios
          .post(url, postData)
          .then((response) => {
            console.log(response.data);
            res.status(200).send(response.data);
          })
          .catch((error) => {
            console.error(error.message);
            // Handle error here
            res.status(500).send(`error ad ${error.message}`);
          });
      } else {
        res.status(404).send("Not found");
      }
    });
  });

export const assignBarcodesFromPurchase = functions
  .runWith(runtimeOpts)
  .https.onRequest(async (req, res) => {
    cors(req, res, async () => {
      if (req.method === "POST") {
        try {
          const companyId = req.body.companyId;
          const cardCompanyName = req.body.cardCompanyName;
          const cardExpDate = req.body.cardExpDate;
          const cardNumber = req.body.cardNumber;
          const cardToken = req.body.cardToken;

          //check if are are not null or empty then create object
          if (
            companyId != undefined ||
            cardCompanyName != undefined ||
            cardExpDate != undefined ||
            cardNumber != undefined ||
            cardToken != undefined
          ) {
            try {
              const companyPaymentMethod = {
                cardCompanyName: cardCompanyName,
                cardExpDate: cardExpDate,
                cardNumber: cardNumber,
                cardToken: cardToken,
                companyId: companyId,
              };
              await firestore()
                .collection("company_payment")
                .doc(companyId)
                .set(companyPaymentMethod);
            } catch (error) {
              console.log(error);
            }
          }

          var companyRef = firestore().collection("companies").doc(companyId);
          var companyDoc = companyRef.get();
          var companyData = (await companyDoc).data();
          if (companyData == undefined) {
            res.status(500).send("Company not found");
            return;
          }
          var companyName = companyData["name"];
          var country = companyData["country"];

          const amount = Number(req.body.amount);
          //get amount barcodes from admin info and add to company, also update global barcodes
          await firestore().runTransaction(async (transaction) => {
            var adminInfoDoc = await transaction.get(
              firestore().collection("admin").doc("info")
            );
            var assignableBarcodes = adminInfoDoc.data()![
              "assignableBarcodes"
            ] as string[];
            if (assignableBarcodes.length < amount) {
              res.status(500).send("Not enough barcodes to assign");
              return;
            }
            let newBarcodes: string[] = assignableBarcodes.slice(0, amount);
            transaction.update(adminInfoDoc.ref, {
              assignableBarcodes: firestore.FieldValue.arrayRemove(
                ...newBarcodes
              ),
            });
            transaction.update(companyRef, {
              assignableBarcodes: firestore.FieldValue.arrayUnion(
                ...newBarcodes
              ),
              barcodesPurchased: firestore.FieldValue.increment(amount),
            });
            var currentDate = firestore.Timestamp.now();
            newBarcodes.forEach((barcode) => {
              transaction.update(
                firestore().collection("global_barcodes").doc(barcode),
                {
                  companyReference: companyRef,
                  companyName: companyName,
                  dateAddedToFarm: currentDate,
                  wasPurchased: true,
                  shipping: country.toLowerCase() === 'united states'
                }
              );
            });
          });
          res.status(200).send("Barcodes assigned");
        } catch (error) {
          res.status(500).send(error);
        }
      }
    });
  });

function decrypt(encryptedText: String) {
  const key = Buffer.from("a8B3fK6mP9rS2vYz", "utf-8"); // The same key used for encryption
  const iv = Buffer.from("g4H8jQ1vX5lN0cW2", "utf-8"); // The same IV used for encryption

  const decipher = crypto.createDecipheriv("aes-128-cbc", key, iv);
  let decrypted = decipher.update(encryptedText, "base64", "utf-8");
  decrypted += decipher.final("utf-8");

  return JSON.parse(decrypted);
}

function fromUrlSafeBase64(urlSafeBase64String: String) {
  return urlSafeBase64String.replace(/-/g, "+").replace(/_/g, "/");
}

//for companies, if locations is null, set it to {}
function setLocationsToEmptyObject() {
  firestore()
    .collection("companies")
    .get()
    .then((snapshot) => {
      snapshot.docs.forEach((doc) => {
        if (doc.data().locations == null) {
          doc.ref.update({ locations: {} });
        }
      });
    });
}

setLocationsToEmptyObject();
