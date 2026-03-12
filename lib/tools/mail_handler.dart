import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class MailHandler {

  static const String _username = 'iConsQU@outlook.com';
  static const String _password = String.fromEnvironment('OUTLOOK_PASS');

  MailHandler._();

  static final _smptServer = SmtpServer(
    'smtp-mail.outlook.com', // smtp.office365.com
    port: 587,
    username: _username, // Your Outlook email
    password: _password,
  );

  static Message get skeletonMessage => Message()
    ..from = Address(_username, 'Queens iCons')
    ..subject = 'Test Email from iCons Management System'
    ..text = 'This is the plain text content.'
    ..html = '<h1>This is an HTML email</h1>';

  static Future<bool> sendEmail(String userEmail) async {
    Message message = skeletonMessage
    ..recipients.add(userEmail);

    try {
      final sendReport = await send(message, _smptServer);
      print('Message sent: ' + sendReport.toString());
      return true;
    } on MailerException catch (e) {
      print('Message not sent. \n' + e.toString());
      return false;
    }
  }
}