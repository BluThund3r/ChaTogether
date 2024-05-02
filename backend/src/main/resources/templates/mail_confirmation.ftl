<!DOCTYPE html>
<html>
<head>
    <title>Welcome Email</title>
</head>
<body>
<h2>Welcome to ChaTogether, ${firstName}!</h2>
<p>We're excited to have you join us. Here are some details about your account:</p>
<ul>
    <li><strong>Email:</strong> ${email}</li>
    <li><strong>Username:</strong> ${username}</li>
    <li><strong>First Name:</strong> ${firstName}</li>
    <li><strong>Last Name:</strong> ${lastName}</li>
</ul>
<p>In order to access your account, you will first have to confirm your email address.</p>
<p>Copy the code below and paste it in the input field on the mail verification screen within the app:</p>
<p style="font-weight: bold; font-size: 2em">${confirmationToken}</p>
<p>Best of wishes,</p>
<p>ChaTogether Team</p>
<small>This is an automated message. Please, do not reply to this email!</small>
</body>
</html>