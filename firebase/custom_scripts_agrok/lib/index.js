"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const admin = require("firebase-admin");
const firebase_admin_1 = require("firebase-admin");
const serviceAccountKeyQAPath = "./serviceAccountKeyQA.json";
const serviceAccountKeyProdPath = "./serviceAccountKeyProd.json";
main();
async function main() {
    const isDebug = false;
    var serviceAccountPath;
    if (isDebug) {
        serviceAccountPath = serviceAccountKeyQAPath;
    }
    else {
        serviceAccountPath = serviceAccountKeyProdPath;
    }
    var serviceAccount = require(serviceAccountPath);
    const firebaseAdmin = admin.initializeApp({
        credential: admin.credential.cert(serviceAccount),
    });
    const db = firebaseAdmin.firestore();
    // const batch1 = db.batch();
    // await updateFarmBarcodeCounts(db, batch1);
    // await batch1.commit();
    // const batch2 = db.batch();
    // await updateAdminInfoBarcodeCounts(db, batch2);
    // await batch2.commit();
    await runPrintFarmDocs(db);
    console.log("success");
}
//print farm docs where companyAdminUserInfo is null print length
async function runPrintFarmDocs(db) {
    var farmDocs = (await (0, firebase_admin_1.firestore)().collection("companies").get()).docs;
    var counter = 0;
    await Promise.all(farmDocs.map(async (farmDoc) => {
        var farmData = farmDoc.data();
        if (farmData == null)
            return;
        var companyAdminUserInfo = farmData["companyAdminUserInfo"];
        if (companyAdminUserInfo == null) {
            console.log(`farmDoc = ${farmDoc.id}`);
            counter++;
        }
    }));
    console.log(`counter = ${counter}`);
}
//get "info" doc from "admin" collection, print "assignedBarcodesAmount" and "usedBarcodesAmount", then create counters assignedCount and usedCount, iterate through docs from "global_barcodes" and, if sampleReference != null increment usedCount by 1, if farmReference != null increment assignedCount by 1, print both
async function getAdminInfoAndGlobalBarcodeCounts(db) {
    var adminInfoDoc = await (0, firebase_admin_1.firestore)().collection("admin").doc("info").get();
    var adminInfoData = adminInfoDoc.data();
    if (adminInfoData == null)
        return;
    var assignedBarcodesAmount = adminInfoData["assignedBarcodesAmount"];
    var usedBarcodesAmount = adminInfoData["usedBarcodesAmount"];
    console.log(`assignedBarcodesAmount = ${assignedBarcodesAmount}, usedBarcodesAmount = ${usedBarcodesAmount}`);
    var assignedCount = 0;
    var usedCount = 0;
    var globalBarcodesDocs = (await (0, firebase_admin_1.firestore)().collection("global_barcodes").get()).docs;
    await Promise.all(globalBarcodesDocs.map(async (globalBarcodeDoc) => {
        var globalBarcodeData = globalBarcodeDoc.data();
        if (globalBarcodeData == null)
            return;
        var sampleReference = globalBarcodeData["sampleReference"];
        var farmReference = globalBarcodeData["farmReference"];
        if (sampleReference != undefined) {
            usedCount++;
        }
        if (farmReference != undefined) {
            assignedCount++;
        }
    }));
    console.log(`assignedCount = ${assignedCount}, usedCount = ${usedCount}`);
}
//iterate through global_barcodes, print barcode, farmReference and companyName
async function runPrintGlobalBarcodes(db) {
    var globalBarcodesDocs = (await (0, firebase_admin_1.firestore)().collection("global_barcodes").get()).docs;
    var counter = 0;
    var barcodes = [];
    await Promise.all(globalBarcodesDocs.map(async (globalBarcodeDoc) => {
        var globalBarcodeData = globalBarcodeDoc.data();
        if (globalBarcodeData == null)
            return;
        var barcode = globalBarcodeData["barcode"];
        var farmReference = globalBarcodeData["farmReference"];
        var companyName = globalBarcodeData["companyName"];
        if (farmReference != null && companyName == null) {
            console.log(`barcode = ${barcode}, farmReference = ${farmReference}, companyName = ${companyName}`);
            counter++;
            barcodes.push({ barcode, farmReference });
        }
    }));
    // var barcodesSliced1 = barcodes.slice(0, 500);
    // var barcodesSliced2 = barcodes.slice(500, 1000);
    // var barcodesSliced3 = barcodes.slice(1000, 1500);
    // var barcodesSliced4 = barcodes.slice(1500, 2000);
    // var barcodeSplited = [
    //   barcodesSliced1,
    //   barcodesSliced2,
    //   barcodesSliced3,
    //   barcodesSliced4,
    // ];
    // await Promise.all(
    //   barcodeSplited.map(async (barcodeList) => {
    //     var firestoreBatch = db.batch();
    //     await Promise.all(
    //       barcodeList.map(async (barcode) => {
    //         var farmReference = barcode.farmReference;
    //         var farmDoc = await farmReference.get();
    //         var farmData = farmDoc.data();
    //         if (farmData == null) return;
    //         var companyName = farmData["name"];
    //         console.log(`barcode = ${barcode}, companyName = ${companyName}`);
    //         firestoreBatch.update(
    //           firestore().collection("global_barcodes").doc(barcode.barcode),
    //           { companyName: companyName }
    //         );
    //       })
    //     );
    //     await firestoreBatch.commit();
    //   })
    // );
    //for each barcode inside barcodes,
}
//print count of barcodes in global_barcodes where sampleReference != null
async function runPrintGlobalBarcodeCount(db) {
    var globalBarcodesDocs = (await (0, firebase_admin_1.firestore)().collection("global_barcodes").get()).docs;
    var counter = 0;
    await Promise.all(globalBarcodesDocs.map(async (globalBarcodeDoc) => {
        var globalBarcodeData = globalBarcodeDoc.data();
        if (globalBarcodeData == null)
            return;
        var sampleReference = globalBarcodeData["sampleReference"];
        if (sampleReference != null) {
            counter++;
        }
    }));
    console.log(`counter = ${counter}`);
}
//print sample doc with id = f7884d49-7032-4193-89a3-3adee18de697
async function runPrintSampleDoc(db) {
    var sampleDoc = await (0, firebase_admin_1.firestore)()
        .collection("samples")
        .doc("e7985f2a-9ec9-4cbd-a8ae-fba0f8cc4bba")
        .get();
    console.log(sampleDoc.data()["changes"][0]);
    console.log(sampleDoc.updateTime);
    console.log(sampleDoc.createTime);
}
//print count of all samples where createdDate is less than a week ago
async function runPrintSampleCount(db) {
    var samplesDocs = (await (0, firebase_admin_1.firestore)()
        .collection("samples")
        .where("createdDate", ">", new Date(Date.now() - 5 * 24 * 60 * 60 * 1000))
        .get()).docs;
    console.log(`samplesDocs length = ${samplesDocs.length}`);
    //set barcodeCounter to 0, then for each sample, get youngSampleBarcode and oldSampleBarcode, for each one that is not null, increment barcodeCounter by 1
    var barcodeCounter = 0;
    await Promise.all(samplesDocs.map(async (sampleDoc) => {
        var sampleData = sampleDoc.data();
        if (sampleData == null)
            return;
        var youngSampleBarcode = sampleData["youngSampleBarcode"];
        var oldSampleBarcode = sampleData["oldSampleBarcode"];
        if (youngSampleBarcode != null) {
            barcodeCounter += 1;
        }
        if (oldSampleBarcode != null) {
            barcodeCounter += 1;
        }
    }));
    console.log(`barcodeCounter = ${barcodeCounter}`);
}
//for each farm, if state is empty string, set state to "province" property
async function runMigrateFarmStates(db) {
    var farmDocs = (await (0, firebase_admin_1.firestore)().collection("companies").get()).docs;
    await Promise.all(farmDocs.map(async (farmDoc) => {
        var farmData = farmDoc.data();
        if (farmData == null)
            return;
        var farmId = farmData["id"];
        var province = farmData["province"];
        var state = farmData["state"];
        if (state == "") {
            console.log(`farmId = ${farmId} , province = ${province}`);
            // await firestore().collection("companies").doc(farmId).update({
            //   state: province,
            // });
        }
    }));
}
//print length of list of global_barcodes where farmReference is not null
async function runFindGlobalBarcodes(db) {
    var globalBarcodesDocs = (await (0, firebase_admin_1.firestore)()
        .collection("global_barcodes")
        .where("farmReference", "!=", null)
        .get()).docs;
    console.log(`globalBarcodesDocs length = ${globalBarcodesDocs.length}`);
}
//get doc "info" from admin collection, get properties assignableBarcodes and scannableBarcodes which are lists of strings, and for each string in each list, query global_barcodes where barcode == this string, and if the doc does not exists, print it
async function runCheckAdminBarcodes(db) {
    var adminDoc = (await (0, firebase_admin_1.firestore)().collection("admin").doc("info").get()).data();
    if (adminDoc == null)
        return;
    var assignableBarcodes = adminDoc["assignableBarcodes"];
    var scannableBarcodes = adminDoc["scannableBarcodes"];
    await Promise.all([...assignableBarcodes, ...scannableBarcodes].map(async (barcode) => {
        var globalBarcodeDoc = (await (0, firebase_admin_1.firestore)()
            .collection("global_barcodes")
            .where("barcode", "==", barcode)
            .get()).docs[0];
        if (!globalBarcodeDoc.exists) {
            console.log(`assignable barcode ${barcode} does not exist`);
        }
    }));
}
//for each farm, set barcodesPurchased to 0, query global_barcodes where farmReference == this farm, and for each doc, if sampleReference is not null, increment usedBarcodesCount by 1, and also if farmReference is not null, increment barcodesAssigned by 1
async function runMigrateCorrectBarcodeCounts(db, batch) {
    var farmDocs = (await (0, firebase_admin_1.firestore)().collection("companies").get()).docs;
    await Promise.all(farmDocs.map(async (farmDoc) => {
        var farmData = farmDoc.data();
        if (farmData == null)
            return;
        var farmId = farmData["id"];
        var farmReference = farmDoc.ref;
        var globalBarcodesDocs = (await (0, firebase_admin_1.firestore)()
            .collection("global_barcodes")
            .where("farmReference", "==", farmReference)
            .get()).docs;
        var barcodesAssigned = 0;
        var usedBarcodesCount = 0;
        await Promise.all(globalBarcodesDocs.map(async (globalBarcodesDoc) => {
            var globalBarcodesData = globalBarcodesDoc.data();
            if (globalBarcodesData == null)
                return;
            if (globalBarcodesData["sampleReference"] != null) {
                usedBarcodesCount += 1;
            }
            if (globalBarcodesData["farmReference"] != null) {
                barcodesAssigned += 1;
            }
        }));
        console.log(`farmId = ${farmId} , OLD barcodesAssigned = ${farmData["barcodesAssigned"]} , usedBarcodesCount = ${farmData["usedBarcodesCount"]} // NEW barcodesAssigned = ${barcodesAssigned} , usedBarcodesCount = ${usedBarcodesCount}`);
        batch.update((0, firebase_admin_1.firestore)().collection("companies").doc(farmId), {
            barcodesAssigned: barcodesAssigned,
            usedBarcodesCount: usedBarcodesCount,
            barcodesPurchased: 0,
        });
    }));
}
//for all samples, set printed as false
async function runBatchAddPrintedProperty(db
// batch: firestore.WriteBatch
) {
    var batch1 = db.batch();
    var samplesDocs = (await (0, firebase_admin_1.firestore)().collection("samples").get()).docs;
    var firstBatch = samplesDocs.slice(0, 500);
    var secondBatch = samplesDocs.slice(500, 1000);
    firstBatch.forEach((sampleDoc) => {
        batch1.update(sampleDoc.ref, { printed: false });
    });
    await batch1.commit();
    console.log("first batch committed");
    var batch2 = db.batch();
    secondBatch.forEach((sampleDoc) => {
        batch2.update(sampleDoc.ref, { printed: false });
    });
    await batch2.commit();
}
//get length of user list with email = ryan.meyersick@valleyag.com
async function runFindUsersWithEmail(db) {
    var userDocs = (await (0, firebase_admin_1.firestore)()
        .collection("users")
        .where("email", "==", "Ryan.meyersick@valleyag.com")
        .get()).docs;
    console.log(`userDocs length = ${userDocs.length}`);
}
//get user doc with email "Jared.heuberger@valleyag", then get all samples submitted by that user, print them, then for that user also print firstName and lastName
async function runFindUserChanges2(db) {
    var userDocs = (await (0, firebase_admin_1.firestore)()
        .collection("users")
        .where("firstName", "==", "JT")
        .where("lastName", "==", "McClellan")
        .get()).docs;
    console.log(`userDocs length = ${userDocs.length}`);
    await Promise.all(userDocs.map(async (userDoc) => {
        var userReference = userDoc.ref;
        var samplesDocs = (await (0, firebase_admin_1.firestore)()
            .collection("samples")
            .where("userReference", "==", userReference)
            .get()).docs;
        console.log(`samplesDocs length = ${samplesDocs.length}`);
        var userData = userDoc.data();
        if (userData == null)
            return;
        var firstName = userData["firstName"];
        var lastName = userData["lastName"];
        console.log(`firstName = ${firstName} , lastName = ${lastName}`);
    }));
}
//for each farm, print usedBarcodeCounts and also query global_barcodes where farmReference == this farm
async function runLogBarcodeCounts8(db) {
    var farmDocs = (await (0, firebase_admin_1.firestore)().collection("companies").get()).docs;
    await Promise.all(farmDocs.map(async (farmDoc) => {
        var farmData = farmDoc.data();
        if (farmData == null)
            return;
        var farmId = farmData["id"];
        var farmReference = farmDoc.ref;
        var globalBarcodesDocs = (await (0, firebase_admin_1.firestore)()
            .collection("global_barcodes")
            .where("farmReference", "==", farmReference)
            .get()).docs.filter((doc) => doc.data()["sampleReference"] != null);
        console.log(`farmId = ${farmId} , usedBarcodeCounts = ${farmData["usedBarcodesCount"]} , globalBarcodesDocs length = ${globalBarcodesDocs.length}`);
    }));
}
//iterate through global_barcodes collection, for each doc that has farmReference not null, and sampleReference as null, get property "barcode" and query if any doc in samples collection has either youngSampleBarcode or oldSampleBarcode equal to that barcode, if so, print length of that list and also print barcode
async function runLogBarcodeCounts7(db) {
    var globalBarcodesDocs = (await (0, firebase_admin_1.firestore)()
        .collection("global_barcodes")
        .where("farmReference", "==", null)
        .get()).docs.filter((doc) => doc.data()["sampleReference"] == null);
    await Promise.all(globalBarcodesDocs.map(async (globalBarcodesDoc) => {
        var globalBarcodesData = globalBarcodesDoc.data();
        if (globalBarcodesData == null)
            return;
        var barcode = globalBarcodesData["barcode"];
        var samplesYoungDocs = (await (0, firebase_admin_1.firestore)()
            .collection("samples")
            .where("youngSampleBarcode", "==", barcode)
            .get()).docs;
        var samplesOldDocs = (await (0, firebase_admin_1.firestore)()
            .collection("samples")
            .where("oldSampleBarcode", "==", barcode)
            .get()).docs;
        console.log(`barcode = ${barcode} , samplesYoungDocs length = ${samplesYoungDocs.length}, samplesOldDocs length = ${samplesOldDocs.length}`);
    }));
}
//iterate through samples collection, get properties youngSampleBarcode and oldSampleBarcode, for each one, if they're not null, query global_barcodes collection where barcode equals youngSampleBarcode or oldSampleBarcode, print length and also if sampleReference is equal to the current sample reference, same for farmReference
async function runLogBarcodeCounts5(db) {
    var samplesDocs = (await (0, firebase_admin_1.firestore)().collection("samples").get()).docs;
    await Promise.all(samplesDocs.map(async (sampleDoc) => {
        var sampleData = sampleDoc.data();
        if (sampleData == null)
            return;
        var sampleId = sampleData["id"];
        var youngSampleBarcode = sampleData["youngSampleBarcode"];
        var oldSampleBarcode = sampleData["oldSampleBarcode"];
        var youngGlobalBarcodesDoc = null;
        if (youngSampleBarcode) {
            var list = await (0, firebase_admin_1.firestore)()
                .collection("global_barcodes")
                .doc(youngSampleBarcode)
                .get();
            if (list.exists) {
                youngGlobalBarcodesDoc = list;
            }
        }
        var oldGlobalBarcodesDoc = null;
        if (oldSampleBarcode) {
            list = await (0, firebase_admin_1.firestore)()
                .collection("global_barcodes")
                .doc(oldSampleBarcode)
                .get();
            if (list.exists) {
                oldGlobalBarcodesDoc = list;
            }
        }
        if ((youngSampleBarcode != null && youngGlobalBarcodesDoc == null) ||
            (oldSampleBarcode != null && oldGlobalBarcodesDoc == null)) {
            console.log(`sampleId = ${sampleId} , youngSB = ${youngSampleBarcode} , oldSB = ${oldSampleBarcode} and youngGlobalBarcodesDoc = ${youngGlobalBarcodesDoc} and oldGlobalBarcodesDoc = ${oldGlobalBarcodesDoc}`);
            // if (youngSampleBarcode != null && youngGlobalBarcodesDoc == null) {
            //   var companyName: String | null = null;
            //   if (sampleData["farmReference"] != null) {
            //     var farmDoc = await sampleData["farmReference"].get();
            //     var farmData = farmDoc.data();
            //     if (farmData != null) {
            //       companyName = farmData["name"];
            //     }
            //   }
            //   await firestore()
            //     .collection("global_barcodes")
            //     .doc(youngSampleBarcode)
            //     .set({
            //       barcode: youngSampleBarcode,
            //       sampleReference: sampleDoc.ref,
            //       farmReference: sampleData["farmReference"],
            //       companyName: companyName,
            //       type: "",
            //     });
            // }
            // if (oldSampleBarcode != null && oldGlobalBarcodesDoc == null) {
            //   var companyName: String | null = null;
            //   if (sampleData["farmReference"] != null) {
            //     var farmDoc = await sampleData["farmReference"].get();
            //     var farmData = farmDoc.data();
            //     if (farmData != null) {
            //       companyName = farmData["name"];
            //     }
            //   }
            //   await firestore()
            //     .collection("global_barcodes")
            //     .doc(oldSampleBarcode)
            //     .set({
            //       barcode: oldSampleBarcode,
            //       sampleReference: sampleDoc.ref,
            //       farmReference: sampleData["farmReference"],
            //       companyName: companyName,
            //       type: "",
            //     });
            // }
        }
    }));
}
//find doc in users collection with email "Jared.heuberger@valleyag.com", then company with name "Valley Ag - Mt. Angel", look for samples submitted by that user (userReference) and that company (farmReference)
async function runFindUserChanges(db) {
    var userDoc = (await (0, firebase_admin_1.firestore)()
        .collection("users")
        .where("email", "==", "jared.heuberger@valleyag.com")
        .get()).docs[0];
    var companyDoc = (await (0, firebase_admin_1.firestore)()
        .collection("companies")
        .where("name", "==", "Valley Ag - Mt. Angel")
        .get()).docs[0];
    var userReference = userDoc.ref;
    var companyReference = companyDoc.ref;
    var samplesDoc = (await (0, firebase_admin_1.firestore)()
        .collection("samples")
        .where("userReference", "==", userReference)
        .where("farmReference", "==", companyReference)
        .get()).docs;
    console.log(`samplesDoc length = ${samplesDoc.length} , userReference = ${userReference.path} , companyReference = ${companyReference.path}`);
}
//iterate through farms collection, for each doc, update "country" to "United States"
async function runBatchChangeFarmCountryToUSA(db, batch) {
    var farmDocs = (await (0, firebase_admin_1.firestore)().collection("companies").get()).docs;
    farmDocs.forEach((farmDoc) => {
        batch.update(farmDoc.ref, { country: "United States", province: "" });
    });
}
//iterate through farms collection, for each doc, query samples collection where farmReference equals farm doc, print length, and do the same with global_barcodes collection
async function runLogBarcodeCounts6(db) {
    var farmDocs = (await (0, firebase_admin_1.firestore)().collection("companies").get()).docs;
    await Promise.all(farmDocs.map(async (farmDoc) => {
        var farmData = farmDoc.data();
        if (farmData == null)
            return;
        var farmReference = farmDoc.ref;
        var samplesDoc = (await (0, firebase_admin_1.firestore)()
            .collection("samples")
            .where("farmReference", "==", farmReference)
            .get()).docs;
        var globalBarcodesDoc = (await (0, firebase_admin_1.firestore)()
            .collection("global_barcodes")
            .where("farmReference", "==", farmReference)
            .get()).docs
            .map((doc) => doc.data())
            .filter((doc) => {
            return doc["sampleReference"] != null;
        });
        console.log(`farm name = ${farmData["name"]} , farm id = ${farmData["id"]} , samplesCount = ${samplesDoc.length} , globalBarcodesCount = ${globalBarcodesDoc.length}`);
    }));
}
//iterate through samples collection, print "changes" (a list) length and also sample id
async function runSeeSampleChanges(db) {
    var samplesDocs = (await (0, firebase_admin_1.firestore)().collection("samples").get()).docs;
    await Promise.all(samplesDocs.map(async (sampleDoc) => {
        var _a;
        var sampleData = sampleDoc.data();
        if (sampleData == null)
            return;
        var sampleId = sampleData["id"];
        var changes = (_a = sampleData["changes"]) !== null && _a !== void 0 ? _a : [];
        console.log(`changes length = ${changes === null || changes === void 0 ? void 0 : changes.length} , sampleId = ${sampleId}`);
    }));
}
//iterate through farms collection, for each farm, query samples collection where farmReference equals farm doc, print length, also query global_barcodes collection where farmReference equals farm doc, print length
async function runLogBarcodeCounts4(db) {
    var farmDocs = (await (0, firebase_admin_1.firestore)().collection("companies").get()).docs;
    await Promise.all(farmDocs.map(async (farmDoc) => {
        console.log("---- starting with farm name = " + farmDoc.data()["name"] + " ----");
        var farmData = farmDoc.data();
        if (farmData == null)
            return;
        var farmReference = farmDoc.ref;
        var farmId = farmData["id"];
        var farmName = farmData["name"];
        var samplesDoc = (await (0, firebase_admin_1.firestore)()
            .collection("samples")
            .where("farmReference", "==", farmReference)
            .get()).docs.map((doc) => doc.data());
        var globalBarcodesDoc = (await (0, firebase_admin_1.firestore)()
            .collection("global_barcodes")
            .where("farmReference", "==", farmReference)
            .get()).docs
            .map((doc) => doc.data())
            .filter((doc) => {
            return doc["sampleReference"] != null;
        });
        var sampleBarcodeCount = 0;
        samplesDoc.forEach((sampleData) => {
            if (sampleData == null)
                return;
            if (sampleData["youngSampleBarcode"] != null &&
                sampleData["youngSampleBarcode"].length > 0) {
                sampleBarcodeCount++;
                if (globalBarcodesDoc.find((doc) => {
                    return doc["barcode"] == sampleData["youngSampleBarcode"];
                }) == null) {
                    // console.log(
                    //   `${sampleData["youngSampleBarcode"]} no esta en global`
                    // );
                }
            }
            if (sampleData["oldSampleBarcode"] != null &&
                sampleData["oldSampleBarcode"].length > 0) {
                sampleBarcodeCount++;
                if (globalBarcodesDoc.find((doc) => {
                    return doc["barcode"] == sampleData["oldSampleBarcode"];
                }) == null) {
                    // console.log(
                    //   `${sampleData["oldSampleBarcode"]} no esta en global barcodes`
                    // );
                }
            }
        });
        var globalBarcodesCount = globalBarcodesDoc.length;
        console.log(`farm name = ${farmName} , farm id = ${farmId} , samplesCount = ${sampleBarcodeCount} , globalBarcodesCount = ${globalBarcodesCount}`);
        console.log("---- end with farm name = " + farmDoc.data()["name"] + " ----");
    }));
}
//iterate through farms collection, for each farm, compare document id with global_barcodes farmReference.id, print count of documents with sampleReference equal to null, then sampleReference not null, also print the farm's usedBarcodesCount and (barcodesAssigned - usedBarcodesCount)
async function runLogBarcodeCounts3(db) {
    var farmDocs = (await (0, firebase_admin_1.firestore)().collection("companies").get()).docs;
    await Promise.all(farmDocs.map(async (farmDoc) => {
        var farmData = farmDoc.data();
        if (farmData == null)
            return;
        var farmReference = farmDoc.ref;
        var farmId = farmData["id"];
        var farmName = farmData["name"];
        var farmUsedCount = farmData["usedBarcodesCount"];
        var farmBarcodesAssigned = farmData["barcodesAssigned"];
        var globalBarcodesDoc = (await (0, firebase_admin_1.firestore)()
            .collection("global_barcodes")
            .where("farmReference", "==", farmReference)
            .get()).docs;
        var globalBarcodesSampleReferenceNullCount = globalBarcodesDoc.filter((globalBarcodesDoc) => globalBarcodesDoc.data()["sampleReference"] == null).length;
        var globalBarcodesSampleReferenceNotNullCount = globalBarcodesDoc.filter((globalBarcodesDoc) => globalBarcodesDoc.data()["sampleReference"] != null).length;
        console.log(`${farmUsedCount == globalBarcodesSampleReferenceNotNullCount} , ${farmBarcodesAssigned - farmUsedCount ==
            globalBarcodesSampleReferenceNullCount} , farmUsedCount = ${farmUsedCount} , farmBarcodesAssigned = ${farmBarcodesAssigned} , globalBarcodesSampleReferenceNullCount = ${globalBarcodesSampleReferenceNullCount} , globalBarcodesSampleReferenceNotNullCount = ${globalBarcodesSampleReferenceNotNullCount}`);
    }));
}
//get info document from admin collection, print usedBarcodesAmount, then create a counter called usedCounter for each farm, add usedBarcodesCount to it, then print the counter
async function runLogBarcodeCounts2(db) {
    var infoDoc = await (0, firebase_admin_1.firestore)().collection("admin").doc("info").get();
    var infoData = infoDoc.data();
    if (infoData == null)
        return;
    var usedBarcodesAmount = infoData["usedBarcodesAmount"];
    console.log(`usedBarcodesAmount = ${usedBarcodesAmount}`);
    var farmCounterUsed = 0;
    var farmDocs = (await (0, firebase_admin_1.firestore)().collection("companies").get()).docs;
    await Promise.all(farmDocs.map(async (farmDoc) => {
        var farmData = farmDoc.data();
        if (farmData == null)
            return;
        var farmUsedCount = farmData["usedBarcodesCount"];
        farmCounterUsed += farmUsedCount;
        console.log(`farm name = ${farmData["name"]} , farm id = ${farmData["id"]} , farmUsedCount = ${farmUsedCount}`);
    }));
    console.log(`farmCounterUsed = ${farmCounterUsed}`);
}
//print "companyAdminUserInfo" from farm with id = 35830b18-2d5f-4834-ae5b-392977dd051d
async function runCompanyAdminUserInfoFromFarm(db) {
    var farmDoc = await (0, firebase_admin_1.firestore)()
        .collection("companies")
        .doc("35830b18-2d5f-4834-ae5b-392977dd051d")
        .get();
    var farmData = farmDoc.data();
    if (farmData == null)
        return;
    var companyAdminUserInfo = farmData["companyAdminUserInfo"];
    console.log(companyAdminUserInfo);
}
//function that takes farm with id = 35830b18-2d5f-4834-ae5b-392977dd051d, get user doc for user with email "jtmcclellan+costagroup@gmail.com" and user with email "Andrew.scheuer@costagroup.com.au", if both are not null, change first user's "farmReferences" array property with the element that has "farmReference" equal to the farm doc, modify it and set isAdmin to false, for the second user, make it true, then change "companyAdminUserInfo" to have fullName, email and userReference to the second user
async function runBatchChangeFarmAdmin(db, batch) {
    var farmDoc = await (0, firebase_admin_1.firestore)()
        .collection("companies")
        .doc("35830b18-2d5f-4834-ae5b-392977dd051d")
        .get();
    var farmData = farmDoc.data();
    if (farmData == null)
        return;
    var farmReference = farmDoc.ref;
    var userDoc1 = await (0, firebase_admin_1.firestore)()
        .collection("users")
        .where("email", "==", "jtmcclellan+costagroup@gmail.com")
        .get();
    var userDoc2 = await (0, firebase_admin_1.firestore)()
        .collection("users")
        .where("email", "==", "Andrew.scheuer@costagroup.com.au")
        .get();
    console.log(`${userDoc1.docs.length} && ${userDoc2.docs.length}`);
    if (userDoc1.docs.length == 1 && userDoc2.docs.length == 1) {
        console.log("0");
        var userDoc1Data = userDoc1.docs[0].data();
        var userDoc2Data = userDoc2.docs[0].data();
        var userDoc1Reference = userDoc1.docs[0].ref;
        var userDoc2Reference = userDoc2.docs[0].ref;
        console.log(`user1RefId = " + ${userDoc1Reference.id} , user2RefId = " + ${userDoc2Reference.id}`);
        var farmReferences1 = userDoc1Data["farmReferences"];
        var farmReferences2 = userDoc2Data["farmReferences"];
        if (farmReferences1 != null && farmReferences2 != null) {
            console.log("1");
            var indexToModify1 = farmReferences1.findIndex((farmReference1) => farmReference1["farmReference"].id == farmReference.id);
            var indexToModify2 = farmReferences2.findIndex((farmReference2) => farmReference2["farmReference"].id == farmReference.id);
            console.log(`indexToModify1 = ${indexToModify1} // indexToModify2 = ${indexToModify2}`);
            if (indexToModify1 != -1 && indexToModify2 != -1) {
                console.log("2");
                farmReferences1[indexToModify1]["isAdmin"] = false;
                farmReferences2[indexToModify2]["isAdmin"] = true;
                var companyAdminUserInfo = {
                    fullName: "Andrew Scheuer",
                    email: "Andrew.scheuer@costagroup.com.au",
                    userReference: userDoc2Reference,
                };
                batch.update(userDoc1Reference, { farmReferences: farmReferences1 });
                batch.update(userDoc2Reference, { farmReferences: farmReferences2 });
                batch.update(farmReference, {
                    companyAdminUserInfo: companyAdminUserInfo,
                });
            }
        }
    }
}
//print id of document in farms collection that has name == "Agro-K R&D"
async function runCheckFarmName(db) {
    var farmDocs = (await (0, firebase_admin_1.firestore)().collection("companies").get()).docs;
    await Promise.all(farmDocs.map(async (farmDoc) => {
        var farmData = farmDoc.data();
        var farmName = farmData["name"];
        if (farmName == "Costa Group") {
            console.log(`farm id: ${farmDoc.id}`);
        }
    }));
}
//print object of docs inside samples collection that have farmReference.id == "925380c2-a54f-4ade-a8bc-6b7109a83607"
async function runCheckFarmReference(db) {
    var sampleDocs = (await (0, firebase_admin_1.firestore)().collection("samples").get()).docs;
    await Promise.all(sampleDocs.map(async (sampleDoc) => {
        var sampleData = sampleDoc.data();
        var farmReference = sampleData["farmReference"];
        if (farmReference != null) {
            var farmReferenceId = farmReference.id;
            if (farmReferenceId == "925380c2-a54f-4ade-a8bc-6b7109a83607") {
                console.log(sampleData);
                console.log("------------ . ----------");
            }
        }
    }));
}
//iterate through users collection, log on console if any doc has "enabled" property undefined
async function runCheckEnabledUndefined(db) {
    var userDocs = (await (0, firebase_admin_1.firestore)().collection("users").get()).docs;
    await Promise.all(userDocs.map(async (userDoc) => {
        var userData = userDoc.data();
        var enabled = userData["enabled"];
        if (enabled == undefined) {
            console.log(`user ${userDoc.id} has enabled undefined`);
        }
    }));
}
//iterate through "farms" collection, for each doc, get "name" property, then iterate through "users" collection, for each doc, check if "farmReferences" which is an array of maps, has an entry where "farmReference" equals the reference of the document, if yes, add the "name" property to that object with key "farmName"
async function runBatchMigrateCompanyAdminUserInfo2(db, batch) {
    // var farmDocs = (await firestore().collection("companies").get()).docs;
    // var mapUpdates = new Map<firestore.DocumentReference, []>();
    // await Promise.all(
    //   farmDocs.map(async (farmDoc) => {
    //     var farmData = farmDoc.data();
    //     var farmName = farmData["name"];
    //     var farmReference = farmDoc.ref;
    //     var userDocs = (await firestore().collection("users").get()).docs;
    //     await Promise.all(
    //       userDocs.map(async (userDoc) => {
    //         var userData = userDoc.data();
    //         var farmReferences = userData["farmReferences"] as [];
    //         if (farmReferences != null) {
    //           var indexToModify = farmReferences.findIndex(
    //             (farmReferenceIter) => {
    //               return (
    //                 (farmReferenceIter["farmReference"] as any).id ==
    //                 farmReference.id
    //               );
    //             }
    //           );
    //           if (indexToModify != -1) {
    //             (farmReferences[indexToModify] as any)["farmName"] = farmName;
    //             console.log(`set farmName to ${farmName} for user ${userDoc.id}`);
    //             batch.update(userDoc.ref, { farmReferences: farmReferences });
    //           }
    //         }
    //       })
    //     );
    //   })
    // );
    // do above procedure but start by users collection
    var userDocs = (await (0, firebase_admin_1.firestore)().collection("users").get()).docs;
    await Promise.all(userDocs.map(async (userDoc) => {
        var userData = userDoc.data();
        var farmReferences = userData["farmReferences"];
        if (farmReferences != null) {
            await Promise.all(farmReferences.map(async (farmReference) => {
                var farmReferenceId = farmReference["farmReference"].id;
                var farmReferenceDoc = await (0, firebase_admin_1.firestore)()
                    .collection("companies")
                    .doc(farmReferenceId)
                    .get();
                var farmReferenceData = farmReferenceDoc.data();
                if (farmReferenceData != null) {
                    var farmName = farmReferenceData["name"];
                    farmReference["farmName"] = farmName;
                    console.log(`set farmName to ${farmName} for user ${userDoc.id}`);
                }
            }));
            batch.update(userDoc.ref, { farmReferences: farmReferences });
        }
    }));
}
//iterate through global_barcodes collection, have one counter called "barcodesAssigned" and "barcodesUsed", for each doc, if farmReference != null but userReference == null, increase barcodesAssigned, if farmReference != null and userReference != null, increase barcodesUsed, then print both values
async function runBatchMigrateGlobalBarcodes(db) {
    var globalBarcodeDocs = (await (0, firebase_admin_1.firestore)().collection("global_barcodes").get()).docs;
    var barcodesAssigned = 0;
    var barcodesUsed = 0;
    await Promise.all(globalBarcodeDocs.map(async (globalBarcodeDoc) => {
        var globalBarcodeData = globalBarcodeDoc.data();
        var farmReference = globalBarcodeData["farmReference"];
        var sampleReference = globalBarcodeData["sampleReference"];
        if (farmReference != null && sampleReference == null) {
            barcodesAssigned++;
        }
        if (farmReference != null && sampleReference != null) {
            barcodesUsed++;
        }
    }));
    console.log("barcodesAssigned: " + barcodesAssigned);
    console.log("barcodesUsed: " + barcodesUsed);
}
//update all documents in "users" collection, if "enabled" property is undefined, set it to true
async function runBatchMigrateAddEnabledFieldToUser(db, batch) {
    var userDocs = (await (0, firebase_admin_1.firestore)().collection("users").get()).docs;
    await Promise.all(userDocs.map(async (userDoc) => {
        var userData = userDoc.data();
        var enabled = userData["enabled"];
        if (enabled == undefined) {
            var body = new Map();
            body.set("enabled", true);
            batch.update(userDoc.ref, Object.fromEntries(body));
        }
    }));
}
//iterate through "farms" collection, for each farm, get properties "barcodesPurchased" and "barcodesAssigned", add both to a counter called "totalBarcodesAssigned", and add "usedBarcodesCount" to a counter called "totalBarcodesUsed". Update "info" document on "admin" collection, set "assignedBarcodesAmount" to "totalBarcodesAssigned" counter and "usedBarcodesAmount" to "totalBarcodesUsed" counter
async function updateAdminInfoBarcodeCounts(db, batch) {
    var farmDocs = (await (0, firebase_admin_1.firestore)().collection("companies").get()).docs;
    var totalBarcodesAssigned = 0;
    var totalBarcodesUsed = 0;
    await Promise.all(farmDocs.map(async (farmDoc) => {
        var farmData = farmDoc.data();
        var barcodesPurchased = farmData["barcodesPurchased"];
        var barcodesAssigned = farmData["barcodesAssigned"];
        var usedBarcodesCount = farmData["usedBarcodesCount"];
        totalBarcodesAssigned += barcodesPurchased + barcodesAssigned;
        totalBarcodesUsed += usedBarcodesCount;
    }));
    var adminInfoDoc = await (0, firebase_admin_1.firestore)().collection("admin").doc("info").get();
    var data = adminInfoDoc.data();
    if (data != null) {
        console.log(`totalBarcodesAssigned = ${totalBarcodesAssigned} / totalBarcodesUsed = ${totalBarcodesUsed} / data.assignedBarcodesAmount = ${data["assignedBarcodesAmount"]} / data.usedBarcodesAmount = ${data["usedBarcodesAmount"]}`);
        var body = new Map();
        body.set("assignedBarcodesAmount", totalBarcodesAssigned);
        body.set("usedBarcodesAmount", totalBarcodesUsed);
        batch.update(adminInfoDoc.ref, Object.fromEntries(body));
    }
    // await batch.commit();
}
//iterate through farms collection, for each farm, get usedBarcodesCount (int), then go through samples collection and filter where farmReference = the current doc's reference, for each sample document, if youngSampleBarcode is not null, increase a counter, same with oldSampleBarcode (use the same counter for both, in the scope of the farm), then log this counter and usedBarcodeCount and the farm name
async function runLogBarcodeCounts(db) {
    var farmDocs = (await (0, firebase_admin_1.firestore)().collection("companies").get()).docs;
    await Promise.all(farmDocs.map(async (farmDoc) => {
        var farmData = farmDoc.data();
        var farmName = farmData["name"];
        var farmReference = farmDoc.ref;
        var usedBarcodesCount = farmData["usedBarcodesCount"];
        var farmBarcodeCount = 0;
        var sampleDocs = (await (0, firebase_admin_1.firestore)()
            .collection("samples")
            .where("farmReference", "==", farmReference)
            .get()).docs;
        await Promise.all(sampleDocs.map(async (sampleDoc) => {
            var sampleData = sampleDoc.data();
            var youngSampleBarcode = sampleData["youngSampleBarcode"];
            var oldSampleBarcode = sampleData["oldSampleBarcode"];
            if (youngSampleBarcode != null) {
                farmBarcodeCount++;
            }
            if (oldSampleBarcode != null) {
                farmBarcodeCount++;
            }
        }));
        console.log(`farmName = ${farmName} / usedBarcodesCount = ${usedBarcodesCount} / farmBarcodeCount = ${farmBarcodeCount}`);
        //update these values
        // var body = new Map<String, any>();
        // body.set("usedBarcodesCount", farmBarcodeCount);
        // batch.update(farmDoc.ref, Object.fromEntries(body));
    }));
}
//iterate through "farms" collection, for each farm, get documentreference, get docs from "global_barcodes" collection where farmReference is equal to farm documentreference, for each doc, if sampleReference is undefined, add to counter "farmBarcodesAssigned", on the farm foreach scope, and if sampleReference is not undefined, add to counter "farmBarcodesUsed"
async function updateFarmBarcodeCounts(db, batch) {
    var farmDocs = (await (0, firebase_admin_1.firestore)().collection("companies").get()).docs;
    await Promise.all(farmDocs.map(async (farmDoc) => {
        var farmData = farmDoc.data();
        var farmBarcodesAssigned = 0;
        var farmBarcodesUsed = 0;
        var farmReference = farmDoc.ref;
        var globalBarcodeDocs = (await (0, firebase_admin_1.firestore)()
            .collection("global_barcodes")
            .where("farmReference", "==", farmReference)
            .get()).docs;
        await Promise.all(globalBarcodeDocs.map(async (globalBarcodeDoc) => {
            var globalBarcodeData = globalBarcodeDoc.data();
            var sampleReference = globalBarcodeData["sampleReference"];
            if (sampleReference != undefined) {
                farmBarcodesUsed++;
            }
            farmBarcodesAssigned++;
        }));
        var body = new Map();
        body.set("barcodesAssigned", farmBarcodesAssigned);
        body.set("usedBarcodesCount", farmBarcodesUsed);
        batch.update(farmDoc.ref, Object.fromEntries(body));
    }));
    await batch.commit();
}
//update doc "info" from collection "admin" with new field "usedBarcodesAmount" set to 0
async function updateAdminInfo(db, batch) {
    var adminInfoDoc = await (0, firebase_admin_1.firestore)().collection("admin").doc("info").get();
    var data = adminInfoDoc.data();
    var body = new Map();
    body.set("usedBarcodesAmount", 0);
    batch.update(adminInfoDoc.ref, Object.fromEntries(body));
    await batch.commit();
}
//iterate through "samples" collection, for each doc, check if farmReference is not undefined, then get farmReference doc, get name property (string) and update sample doc setting "farmName" to farm name
async function updateFarmName(db, batch) {
    var sampleDocs = (await (0, firebase_admin_1.firestore)().collection("samples").get()).docs;
    await Promise.all(sampleDocs.map(async (sampleDoc) => {
        var sampleData = sampleDoc.data();
        var farmReference = sampleData["farmReference"];
        if (farmReference != undefined) {
            var farmDoc = await farmReference.get();
            if (farmDoc.exists) {
                var farmData = farmDoc.data();
                var farmName = farmData["name"];
                var body = new Map();
                body.set("farmName", farmName);
                batch.update(sampleDoc.ref, Object.fromEntries(body));
            }
        }
    }));
    await batch.commit();
}
//iterate through "samples" collection, for each doc, check if youngSampleBarcode or oldSampleBarcode starts with "XXX", if it does, delete the doc.
async function deleteSamplesXXX(db, batch) {
    var sampleDocs = (await (0, firebase_admin_1.firestore)().collection("samples").get()).docs;
    var count = 0;
    await Promise.all(sampleDocs.map(async (sampleDoc) => {
        var sampleData = sampleDoc.data();
        var youngSampleBarcode = sampleData["youngSampleBarcode"];
        var oldSampleBarcode = sampleData["oldSampleBarcode"];
        if ((youngSampleBarcode != undefined &&
            youngSampleBarcode.startsWith("XXX")) ||
            (oldSampleBarcode != undefined && oldSampleBarcode.startsWith("XXX"))) {
            count++;
            batch.delete(sampleDoc.ref);
        }
    }));
    await batch.commit();
    console.log("deleted " + count + " samples");
}
//iterate through "global_barcodes" collection, for each doc, check if barcode string starts with "XXX", if yes, delete the doc, also delete all sample docs from "samples" collection where youngSampleBarcode or oldSampleBarcode are equal to this barcode string
async function deleteBarcodes(db, batch) {
    var globalBarcodeDocs = (await (0, firebase_admin_1.firestore)().collection("global_barcodes").get()).docs;
    await Promise.all(globalBarcodeDocs.map(async (globalBarcodeDoc) => {
        var globalBarcodeData = globalBarcodeDoc.data();
        var barcode = globalBarcodeData["barcode"];
        if (barcode.startsWith("XXX")) {
            var sampleReference = globalBarcodeData["sampleReference"];
            if (sampleReference != undefined) {
                var sampleDoc = await sampleReference.get();
                if (sampleDoc.exists) {
                    batch.delete(sampleReference);
                }
            }
            batch.delete(globalBarcodeDoc.ref);
        }
    }));
    await batch.commit();
}
//iterate through "farms" collection, for each farm, iterate through "global_barcodes" collection and check which docs have sampleReference.id == farm.id, return count as update as usedBarcodesCount to the farm
async function setUsedBarcodeCount(db, batch) {
    var farmDocs = (await (0, firebase_admin_1.firestore)().collection("companies").get()).docs;
    await Promise.all(farmDocs.map(async (farmDoc) => {
        var farmReference = farmDoc.ref;
        var farmData = farmDoc.data();
        var farmId = farmData["id"];
        var globalBarcodeDocs = (await (0, firebase_admin_1.firestore)().collection("global_barcodes").get()).docs;
        var usedBarcodesCount = 0;
        var assignedBarcodesCount = 0;
        globalBarcodeDocs.forEach((globalBarcodeDoc) => {
            var globalBarcodeData = globalBarcodeDoc.data();
            var sampleReference = globalBarcodeData["sampleReference"];
            var farmReference = globalBarcodeData["farmReference"];
            if (farmReference != undefined) {
                if (sampleReference != undefined && farmReference.id == farmId) {
                    usedBarcodesCount++;
                }
                if (farmReference.id == farmId) {
                    assignedBarcodesCount++;
                }
            }
        });
        var body = new Map();
        body.set("usedBarcodesCount", usedBarcodesCount);
        body.set("barcodesAssigned", assignedBarcodesCount);
        body.set("barcodesPurchased", 0);
        batch.update(farmReference, Object.fromEntries(body));
    }));
    await batch.commit();
}
// async function runBatchMigrateFarmFields(
//   db: firestore.Firestore,
//   batch: admin.firestore.WriteBatch
// ): Promise<void> {
//   var adminInfoDoc = await firestore().collection("admin").doc("info").get();
//   var data = adminInfoDoc.data();
//   if (data != null) {
//     var barcodes = data["barcodes"];
//   }
//   var body = new Map<String, any>();
//   body.set("barcodes", admin.firestore.FieldValue.delete());
//   body.set("assignableBarcodes", barcodes);
//   adminInfoDoc.ref.update(Object.fromEntries(body));
// }
// async function runBatchMigrateFarmFields(
//   db: firestore.Firestore,
//   batch: admin.firestore.WriteBatch
// ): Promise<void> {
//   var farmDocs = (await firestore().collection("companies").get()).docs;
//   farmDocs.forEach(async (farmDoc) => {
//     var farmReference = farmDoc.ref;
//     var body = new Map<String, any>();
//     body.set("crops", {});
//     body.set("locations", {});
//     body.set("growers", {});
//     batch.update(farmReference, Object.fromEntries(body));
//   });
// }
// async function runBatchMigrateBarcodes(
//   db: firestore.Firestore,
//   batch: admin.firestore.WriteBatch
// ): Promise<void> {
//   //migrate barcodes from admin
//   var adminInfo = await firestore().collection("admin").doc("info").get();
//   var data = adminInfo.data();
//   var assignableBarcodes = data!["assignableBarcodes"] as string[];
//   var scannableBarcodes = data!["scannableBarcodes"] as string[];
//   var barcodesToAddToGlobalList: {
//     barcode: string;
//     type: string;
//     farmReference?: any;
//     sampleReference?: firestore.DocumentReference<firestore.DocumentData>;
//     companyName?: string;
//     createdDate?: Date;
//   }[] = [];
//   assignableBarcodes.forEach((barcode) => {
//     barcodesToAddToGlobalList.push({
//       barcode: barcode,
//       type: "requestable",
//     });
//   });
//   scannableBarcodes.forEach((barcode) => {
//     barcodesToAddToGlobalList.push({
//       barcode: barcode,
//       type: "scannable",
//     });
//   });
//   //
//   //migrate barcodes from farms
//   var farmDocs = (await firestore().collection("companies").get()).docs;
//   farmDocs.forEach(async (farmDoc) => {
//     var data = farmDoc.data()!;
//     var assignableBarcodes = data["assignableBarcodes"] as string[];
//     console.log(`new farm. id = ${data["id"]}`);
//     assignableBarcodes.forEach((barcode) => {
//       console.log(`barcode = ${barcode}`);
//       barcodesToAddToGlobalList.push({
//         barcode: barcode,
//         type: "requestable",
//         farmReference: farmDoc.ref,
//         companyName: data["name"],
//       });
//     });
//   });
//   //
//   //migrate barcodes from samples
//   var sampleDocs = (await firestore().collection("samples").get()).docs;
//   sampleDocs.forEach(async (sampleDoc) => {
//     var data = sampleDoc.data()!;
//     var farmReference = data["farmReference"] as
//       | firestore.DocumentReference
//       | undefined;
//     var farmName;
//     if (farmReference != undefined) {
//       var farmData = (await farmReference.get()).data()!;
//       farmName = farmData["name"];
//     }
//     var youngSampleBarcode = data["youngSampleBarcode"] as string | undefined;
//     var oldSampleBarcode = data["oldSampleBarcode"] as string | undefined;
//     if (youngSampleBarcode != undefined) {
//       barcodesToAddToGlobalList.push({
//         barcode: youngSampleBarcode,
//         type: "",
//         sampleReference: sampleDoc.ref,
//         farmReference: farmReference,
//         companyName: farmName,
//       });
//     }
//     if (oldSampleBarcode != undefined) {
//       barcodesToAddToGlobalList.push({
//         barcode: oldSampleBarcode,
//         type: "",
//         sampleReference: sampleDoc.ref,
//         farmReference: farmReference,
//         companyName: farmName,
//       });
//     }
//   });
//   //
//   console.log(`lets update ${barcodesToAddToGlobalList.length}`);
//   //add all new barcodes to global barcode list
//   var slicedBarcodes1 = barcodesToAddToGlobalList.slice(0, 498);
//   var slicedBarcodes2 = barcodesToAddToGlobalList.slice(498, 908);
//   const batch1 = db.batch();
//   slicedBarcodes1.forEach((barcodeItem) => {
//     batch1.set(
//       firestore().collection("global_barcodes").doc(barcodeItem.barcode),
//       barcodeItem
//     );
//   });
//   await batch1.commit();
//   const batch2 = db.batch();
//   slicedBarcodes2.forEach((barcodeItem) => {
//     batch2.set(
//       firestore().collection("global_barcodes").doc(barcodeItem.barcode),
//       barcodeItem
//     );
//   });
//   await batch2.commit();
//   //
// }
// async function runBatchMigrateFarmFields(
//   db: firestore.Firestore,
//   batch: admin.firestore.WriteBatch
// ): Promise<void> {
//   var farmDocs = (await firestore().collection("companies").get()).docs;
//   farmDocs.forEach(async (farmDoc) => {
//     var farmReference = farmDoc.ref;
//     var body = new Map<String, any>();
//     body.set("assignableBarcodes", []);
//     body.set("scannableBarcodes", []);
//     batch.update(farmReference, Object.fromEntries(body));
//   });
// }
// async function runBatchMigrateFarmFields(
//   db: firestore.Firestore,
//   batch: admin.firestore.WriteBatch
// ): Promise<void> {
//   var farmDocs = (await firestore().collection("companies").get()).docs;
//   farmDocs.forEach(async (farmDoc) => {
//     var farmReference = farmDoc.ref;
//     var body = new Map<String, any>();
//     body.set("growers", {});
//     body.set("locations", {});
//     body.set("cultivations", {});
//     body.set("treatments", admin.firestore.FieldValue.delete());
//     batch.update(farmReference, Object.fromEntries(body));
//   });
// }
// async function runBatchMigrateTreatments(
//   db: firestore.Firestore,
//   batch: admin.firestore.WriteBatch
// ): Promise<void> {
//   var inviteDocs = (await firestore().collection("invites").get()).docs;
//   // var currentDate = Date.now();
//   await Promise.all(
//     inviteDocs.map(async (inviteDoc) => {
//       var invite = inviteDoc.data();
//       if (invite == null) return;
//       console.log(`created.. ${invite.created.toDate()}`);
//       // var inviteCreatedDate: Date = invite.created.toDate();
//       // if (
//       //   (currentDate - inviteCreatedDate.getTime()) / (1000 * 3600 * 24) >
//       //   30
//       // ) {
//       var inviteId = inviteDoc.ref.id;
//       await inviteDoc.ref.delete();
//       var farmReference: firestore.DocumentReference = invite.invitedTo;
//       var body = new Map<String, Object>();
//       body.set(`invitedUsers.${inviteId}`, admin.firestore.FieldValue.delete());
//       await farmReference.update(Object.fromEntries(body));
//       // }
//     })
//   );
// }
// async function runBatchMigrateLocations(
//   db: firestore.Firestore,
//   batch: admin.firestore.WriteBatch
// ): Promise<void> {
//   var farmDocs = await db.collection("companies").get();
//   farmDocs.forEach((farmDoc) => {
//     var farm = farmDoc.data();
//     var locations = farm["locations"];
// if (farm.size > 0) {
//   var entry = Object.entries(farm.get("locations"))[0];
//   if (entry.length > 0) console.log(`printing.. ${Object.entries(entry)}`);
//   else console.log("vacio");
// } else console.log("vacio 2");
// var locationValues = [];
// var iter = 0;
// var locations = farm.locations as Map<String, Object>;
// for (var location in locations) {
//   locationValues[iter] = locations.get(location);
//   iter++;
// }
// console.log(`list is ${locationValues}`);
//   batch.update(farmDoc.ref, {
//     locations: Object.keys(locations).map(
//       (locationKey) => locations[locationKey]["title"]
//     ),
//   });
// });
// async function runBatchMigrateAddTreatmentList(
//   db: firestore.Firestore,
//   batch: admin.firestore.WriteBatch
// ): Promise<void> {
//   var farmDocs = await db.collection("companies").get();
//   farmDocs.forEach((farmDoc) => {
// var farm = farmDoc.data();
// var locations = farm["locations"];
// if (farm.size > 0) {
//   var entry = Object.entries(farm.get("locations"))[0];
//   if (entry.length > 0) console.log(`printing.. ${Object.entries(entry)}`);
//   else console.log("vacio");
// } else console.log("vacio 2");
// var locationValues = [];
// var iter = 0;
// var locations = farm.locations as Map<String, Object>;
// for (var location in locations) {
//   locationValues[iter] = locations.get(location);
//   iter++;
// }
// console.log(`list is ${locationValues}`);
//     if (farmDoc.data() != null && farmDoc.data()["crops"] == null) {
//       batch.update(farmDoc.ref, {
//         // treatments: {},
//         crops: {},
//       });
//     }
//   });
// }
// async function runBatchMigrateTreatments(
//   db: firestore.Firestore,
//   batch: admin.firestore.WriteBatch
// ): Promise<void> {
//   var farmDocs = await db.collection("companies").get();
//   farmDocs.forEach((farmDoc) => {
//     var farm = farmDoc.data();
//     var farmCultivations = farm["cultivations"];
//     if (farmCultivations != null) {
//       return;
//       var cultivationsMap = new Map<String, String[]>();
//       (farmCultivations as String[]).forEach((cultivation) => {
//         cultivationsMap.set(cultivation, []);
//       });
//       console.log(cultivationsMap);
// var locations = farm["locations"];
// if (farm.size > 0) {
//   var entry = Object.entries(farm.get("locations"))[0];
//   if (entry.length > 0) console.log(`printing.. ${Object.entries(entry)}`);
//   else console.log("vacio");
// } else console.log("vacio 2");
// var locationValues = [];
// var iter = 0;
// var locations = farm.locations as Map<String, Object>;
// for (var location in locations) {
//   locationValues[iter] = locations.get(location);
//   iter++;
// }
// console.log(`list is ${locationValues}`);
// batch.update(farmDoc.ref, {
//   cultivations: Object.fromEntries(cultivationsMap),
// treatments: {},
// treatments: admin.firestore.FieldValue.delete(),
// });
//   } else {
//     batch.update(farmDoc.ref, {
//       cultivations: {},
//       // treatments: {},
//       // treatments: admin.firestore.FieldValue.delete(),
//     });
//   }
// });
// }
//function that iterates through "users" collection, then for each doc, iterate through "farmReferences" list, for each item, if item.isAdmin is true, get farm document from item.farmReference and update the doc field "companyAdminUserInfo" with this map: {email: user.email, fullName: `${user.firstName} ${user.lastName}`, userReference: user.reference}
async function runBatchMigrateCompanyAdminUserInfo(db, batch) {
    var userDocs = await db.collection("users").get();
    await Promise.all(userDocs.docs.map(async (userDoc) => {
        var user = userDoc.data();
        var farmReferences = user["farmReferences"];
        if (farmReferences != null) {
            await Promise.all(farmReferences
                .filter((item) => item.isAdmin == true)
                .map(async (userFarmCombo) => {
                var farmDoc = await userFarmCombo.farmReference.get();
                if (farmDoc.exists) {
                    var companyAdminUserInfo = {
                        email: user.email,
                        fullName: `${user.firstName} ${user.lastName}`,
                        userReference: userDoc.ref,
                    };
                    console.log(`let's set user ${user.email} as admin of farm ${farmDoc.data()["name"]}`);
                    batch.update(farmDoc.ref, {
                        companyAdminUserInfo: companyAdminUserInfo,
                    });
                }
            }));
        }
    }));
}
//# sourceMappingURL=index.js.map