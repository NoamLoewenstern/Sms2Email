import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import * as nodemailer from 'nodemailer';

import { UserDocumnet, UserMessage } from './firestore-docs-types';

const transport = nodemailer.createTransport({
  host: process.env.SENDINBLUE_SMTP_HOST,
  port: Number(process.env.SENDINBLUE_SMTP_PORT),
  auth: {
    user: process.env.SENDINBLUE_EMAIL,
    pass: process.env.SENDINBLUE_PASSWORD,
  },
  // apiKey: process.env.SENDINBLUE_API_KEY,
  // secure: true,
  tls: {
    rejectUnauthorized: true,
    ciphers: 'SSLv3',
  },
});

// firebase Trigger on user auth creation add to collection users
const usersCollectionName = 'users';
const subCollectionName = 'messages';

export const sendEmailOnMessageCreate = functions.firestore
  .document(`${usersCollectionName}/{userId}/${subCollectionName}/{messageId}`)
  .onCreate(async (snap, context) => {
    const { sender: senderNumber, text } = snap.data() as UserMessage;
    const userId = context.params.userId;
    const messageId = context.params.messageId;

    // get user data from users collection
    const user = await admin.firestore().collection(usersCollectionName).doc(userId).get();
    const { email } = user.data() as UserDocumnet;
    const RECIPIENT_EMAIL = email;
    try {
      await transport.sendMail({
        from: 'sms2email@sms2emailapp.com',
        to: RECIPIENT_EMAIL,
        subject: `New message from ${senderNumber}`,
        text: `New message from: ${senderNumber}\n-----\n${text}\n\n-----`,
      });
      console.log(`Email sent to ${RECIPIENT_EMAIL} for message ${messageId}`);
    } catch (error) {
      console.error(error);
    }
  });
