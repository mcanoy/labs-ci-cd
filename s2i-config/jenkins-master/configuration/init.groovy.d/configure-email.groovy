import hudson.model.*;
import jenkins.model.*;
import hudson.tools.*;
import hudson.util.Secret;

import java.util.logging.Level
import java.util.logging.Logger

final def LOG = Logger.getLogger("LABS")

// Check if enabled
def smtpServer = System.getenv('SMTP_SERVER')
if(!smtpServer?.trim()) {
  LOG.log(Level.INFO, '--> SMTP_SERVER not confgiured. Skipping email configuration...' )
  return
}

LOG.log(Level.INFO, '--> Email configuration start ...')

// Variables
def userName = System.getenv('SMTP_USER_NAME')
def password = System.getenv('SMTP_PASSWORD')
def port = System.getenv('SMTP_PORT')
def replyTo = System.getenv('SMTP_REPLY_TO')
def charSet = System.getenv('SMTP_CHARSET')
def sslString = (System.getenv('SMTP_USE_SSL'))
def ssl = true;

if(!charSet?.trim()) {
  charSet = "UTF-8"
}

if(!sslString?.trim() || sslString.toUpperCase() == 'FALSE') {
  ssl = false;
  sslString = 'false'
}

// Constants
def instance = Jenkins.getInstance()
def mailServer = instance.getDescriptor("hudson.tasks.Mailer")
def jenkinsLocationConfiguration = JenkinsLocationConfiguration.get()
def extmailServer = instance.getDescriptor("hudson.plugins.emailext.ExtendedEmailPublisher")

//Jenkins Location
jenkinsLocationConfiguration.setAdminAddress(userName)
jenkinsLocationConfiguration.save()

//E-mail Server
mailServer.setSmtpAuth(userName, password)
mailServer.setSmtpHost(smtpServer)
mailServer.setSmtpPort(port)
mailServer.setCharset(charSet)
mailServer.setUseSsl(ssl);

//Extended-Email
extmailServer.smtpAuthUsername=userName
extmailServer.smtpAuthPassword=Secret.fromString(password)
extmailServer.smtpHost=smtpServer
extmailServer.smtpPort=port
extmailServer.charset=charSet
extmailServer.useSsl=ssl
extmailServer.defaultSubject="\$PROJECT_NAME - Build # \$BUILD_NUMBER - \$BUILD_STATUS!"
extmailServer.defaultBody="\$PROJECT_NAME - Build # \$BUILD_NUMBER - \$BUILD_STATUS:\n\nCheck console output at \$BUILD_URL to view the results."

// Save the state
instance.save()

LOG.log(Level.INFO, "<-- Email configuration complete")
