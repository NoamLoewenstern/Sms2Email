import { config } from 'firebase-functions';
import * as admin from 'firebase-admin';

// admin.initializeApp(config().firebase);
admin.initializeApp();

export * from 'firebase-functions';
