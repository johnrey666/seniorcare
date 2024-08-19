const functions = require('firebase-functions');
const admin = require('firebase-admin');
const sgMail = require('@sendgrid/mail');

admin.initializeApp();
sgMail.setApiKey(functions.config().sendgrid.key);

exports.sendVerificationEmail = functions.https.onCall((data, context) => {
  const msg = {
    to: data.email,
    from: '07209292@dwc-legazpi.edu',
    subject: 'Verification Code',
    text: `Your verification code is ${data.code}`,
  };

  return sgMail.send(msg)
    .then(() => {
      return { success: true };
    })
    .catch(error => {
      console.error('Error sending email:', error);
      throw new functions.https.HttpsError('internal', 'Unable to send email');
    });
});
