import * as admin from "firebase-admin";
import * as excel from "exceljs";
import * as path from "path";
import * as os from "os";

function getYesterdaysDatePresentation(): String {
  var yesterday = getYesterdayDate();
  return `${yesterday.getMonth() + 1
    }_${yesterday.getDate()}_${yesterday.getFullYear()}`;
}

function getYesterdaysDatePresentationWithSlash(): String {
  var yesterday = getYesterdayDate();
  return `${yesterday.getMonth() + 1
    }/${yesterday.getDate()}/${yesterday.getFullYear()}`;
}

function getYesterdayDate(): Date {
  var yesterday = new Date(new Date().valueOf() - 1000 * 60 * 60 * 24);
  setDateToBeginningOfDate(yesterday);
  return yesterday;
}

//format Date object to mm/dd/yyyy
function formatDate(date: Date | undefined): String {
  if (date == undefined) return "";
  return date.toLocaleDateString("en-US", {
    year: "numeric",
    month: "2-digit",
    day: "2-digit",
  });
}

//function like getYesterday() but for today
function getTodayDate(): Date {
  var today = new Date();
  setDateToBeginningOfDate(today);
  return today;
}

function setDateToBeginningOfDate(date: Date) {
  date.setHours(0, 0, 0, 0);
}

function setExcelSheetHeaderStyle(excelSheet: excel.Worksheet) {
  var header = excelSheet.getRow(1);
  header.font = { bold: true };
  header.alignment = { horizontal: "center", vertical: "middle" };
  header.fill = {
    type: "pattern",
    pattern: "solid",
    fgColor: { argb: "FF079665" },
  };
  header.font = { color: { argb: "FFFFFFFF" }, bold: true };
  header.height = 20;
}

function addExcelSheetHeaders(excelSheet: excel.Worksheet) {
  excelSheet.columns = [
    { key: "youngSampleBarcode", header: "Young Sample Barcode", width: 30 },
    { key: "oldSampleBarcode", header: "Old Sample Barcode", width: 30 },
    { key: "grower", header: "Grower", width: 30 },
    { key: "farm", header: "Farm", width: 30 },
    { key: "field", header: "Field", width: 30 },
    { key: "crop", header: "Crop", width: 30 },
    { key: "treatment", header: "Treatment", width: 30 },
    { key: "variety", header: "Variety", width: 30 },
    { key: "notes", header: "Notes", width: 30 },
    { key: "sampleCollectedDate", header: "Sample Collected Date", width: 30 },
    {
      key: "sampleCreatedDate",
      header: "Sample Created Date",
      width: 30,
    },
    { key: "status", header: "Status", width: 30 },
    {
      key: "submittedByFullName",
      header: "Submitted By - Full name",
      width: 30,
    },
    { key: "submittedByEmail", header: "Submitted By - Email", width: 30 },
    { key: "assignedToFullName", header: "Assigned to - Full name", width: 30 },
    { key: "assignedToEmail", header: "Assigned to - Email", width: 30 },
    {
      key: "companyAdminFullName",
      header: "Company admin - Full name",
      width: 30,
    },
    { key: "companyAdminEmail", header: "Company admin - Email", width: 30 },
  ];
  setExcelSheetHeaderStyle(excelSheet);
}

function addExcelSheetRows(
  excelSheet: excel.Worksheet,
  samples: SampleModel[]
) {
  samples.forEach((sample) => {
    console.log(`adding row...`);
    excelSheet.addRow({
      youngSampleBarcode: sample.youngSampleBarcode,
      oldSampleBarcode: sample.oldSampleBarcode,
      grower: sample.grower,
      farm: sample.locationPlot,
      field: sample.cultivation,
      crop: sample.crop,
      variety: sample.variety,
      notes: sample.notes,
      treatment: sample.treatment,
      sampleCollectedDate: formatDate(sample.sampleDate?.toDate()),
      sampleCreatedDate: formatDate(sample.createdDate?.toDate()),
      status: sample.status,
      submittedByFullName: sample.submittedByFullName,
      submittedByEmail: sample.submittedByEmail,
      assignedToFullName: sample.assignedToFullName,
      assignedToEmail: sample.assignedToEmail,
      companyAdminFullName: sample.companyAdminFullName,
      companyAdminEmail: sample.companyAdminEmail,
    });
  });
}

interface UserEmailAndFullName {
  email: string;
  fullName: string;
}

async function getUserEmailAndFullName(
  userRef: admin.firestore.DocumentReference
): Promise<UserEmailAndFullName> {
  var userDoc = (await userRef.get()).data()!;
  var fullName = `${userDoc["firstName"]} ${userDoc["lastName"]}`;
  var email = userDoc["email"];
  return { email, fullName };
}

async function getSamplesFromDocs(
  docs: admin.firestore.QuerySnapshot<admin.firestore.DocumentData>,
  firebaseAdmin: admin.app.App
) {
  var samples: SampleModel[] = [];
  await Promise.all(
    docs.docs.map(async (doc) => {
      try {
        var sample = doc.data();
        if (sample["userReference"] != undefined) {
          var { email, fullName } = await getUserEmailAndFullName(
            sample["userReference"]
          );
          sample.submittedByEmail = email;
          sample.submittedByFullName = fullName;
        }
        if (sample["assignedTo"] != undefined) {
          var { email, fullName } = await getUserEmailAndFullName(
            sample["assignedTo"]
          );
          sample.assignedToEmail = email;
          sample.assignedToFullName = fullName;
        }
        if (sample["farmReference"] != undefined) {
          try {
            var farmReference = sample["farmReference"];
            var userDocs = await firebaseAdmin
              .firestore()
              .collection("users")
              .where("farmReferences", "array-contains", {
                farmReference: farmReference,
                isAdmin: true,
              })
              .get();
            if (userDocs.size > 0) {
              var userData = userDocs.docs[0].data()!;
              var fullName = `${userData["firstName"]} ${userData["lastName"]}`;
              var emails: String = userData["email"];
              sample.companyAdminEmail = emails;
              sample.companyAdminFullName = fullName;
            }
          } catch (e) {
            console.log("error getting farm doc", e);
          }
        }
        samples.push(sample);
      } catch (e) {
        console.log("error parsing sample", e);
      }
    })
  );
  console.log(`found ${samples.length} samples`);
  return samples;
}

export interface SampleModel {
  youngSampleBarcode?: string;
  oldSampleBarcode?: string;
  grower?: string;
  locationPlot?: string; //farm
  treatment?: string;
  cultivation?: string; //field
  crop?: string;
  variety?: string;
  notes?: string;
  sampleDate?: admin.firestore.Timestamp;
  createdDate?: admin.firestore.Timestamp;
  status?: string;
  submittedByFullName?: string;
  submittedByEmail?: string;
  assignedToFullName?: string;
  assignedToEmail?: string;
  companyAdminFullName?: string;
  companyAdminEmail?: string;
}

export async function createSampleExcelSheetAndSendEmail(
  firebaseAdmin: admin.app.App
) {
  //get the code i had to download file from firebase storage
  var storage = firebaseAdmin.storage();
  var bucket = storage.bucket("gs://agro-k-dev.appspot.com");

  var yesterday = getYesterdayDate();
  var today = getTodayDate();
  var sampleDocs = await firebaseAdmin
    .firestore()
    .collection("samples")
    .where("createdDate", ">=", yesterday)
    .where("createdDate", "<", today)
    .get();
  var samples: SampleModel[] = await getSamplesFromDocs(
    sampleDocs,
    firebaseAdmin
  );

  //Creating New Workbook
  var workbook = new excel.Workbook();
  //Get WorkBook
  var sheet = workbook.addWorksheet("Sheet1");

  var yesterdayString = getYesterdaysDatePresentation();
  var yesterdayStringWithSlash = getYesterdaysDatePresentationWithSlash();
  var fileName = `samples_${yesterdayString}.xlsx`;
  // set path for file
  const tempFilePath = path.join(os.tmpdir(), fileName);

  addExcelSheetHeaders(sheet);
  addExcelSheetRows(sheet, samples);

  await workbook.xlsx.writeFile(tempFilePath);

  const result = await bucket.upload(tempFilePath, {
    destination: fileName,
  });

  var signedUrl = await result[0].getSignedUrl({
    action: "read",
    expires: "03-17-2035", // choose a date
  });
  const emailData = {
    to: ["sean.jacobs@agro-k.rovensa.com"], // ["thomas@5nerdssoftware.com"],
    message: {
      subject: `Samples from ${yesterdayStringWithSlash}`,
      html: ``,
      attachments: [
        {
          path: signedUrl[0],
        },
      ],
    },
  };

  const emailRef = firebaseAdmin.firestore().collection("mail").doc();

  await emailRef.set(emailData);
  console.log(`id is ${emailRef.id}`);

  console.log("done");
}

export async function createExcelSheetWithDeletedSamples(
  firebaseAdmin: admin.app.App,
  sampleIds: string[]
) {
  var storage = firebaseAdmin.storage();
  var bucket = storage.bucket("gs://agro-k-dev.appspot.com");
  var workbook = new excel.Workbook();
  var sheet = workbook.addWorksheet("Sheet1");
  var fileName = `deleted_samples_${Date.now()}.xlsx`;
  const tempFilePath = path.join(os.tmpdir(), fileName);
  sheet.columns = [{ key: "sampleId", header: "Sample ID", width: 30 }];
  setExcelSheetHeaderStyle(sheet);
  sampleIds.forEach((sampleId) => {
    sheet.addRow({
      sampleId: sampleId,
    });
  });
  await workbook.xlsx.writeFile(tempFilePath);

  const result = await bucket.upload(tempFilePath, {
    destination: fileName,
  });

  var signedUrl = await result[0].getSignedUrl({
    action: "read",
    expires: "03-17-2035", // choose a date
  });
  const emailData = {
    to: ["sean.jacobs@agro-k.rovensa.com"], // ["thomas@5nerdssoftware.com"],
    message: {
      subject: `Deleted Samples from last month.`,
      html: ``,
      attachments: [
        {
          path: signedUrl[0],
        },
      ],
    },
  };
  console.log("sending email");

  const emailRef = firebaseAdmin.firestore().collection("mail").doc();

  await emailRef.set(emailData);
}

export async function createSampleExcelSheetFromList(
  firebaseAdmin: admin.app.App,
  samples: SampleModel[]
) {
  var storage = firebaseAdmin.storage();
  var bucket = storage.bucket("gs://agro-k-dev.appspot.com");
  var workbook = new excel.Workbook();
  var sheet = workbook.addWorksheet("Sheet1");
  var fileName = `samples_${Date.now()}.xlsx`;
  const tempFilePath = path.join(os.tmpdir(), fileName);

  addExcelSheetHeaders(sheet);
  addExcelSheetRows(sheet, samples);

  await workbook.xlsx.writeFile(tempFilePath);

  const result = await bucket.upload(tempFilePath, {
    destination: fileName,
  });

  var signedUrl = await result[0].getSignedUrl({
    action: "read",
    expires: "03-17-2035", // choose a date
  });
  return signedUrl[0];
}
