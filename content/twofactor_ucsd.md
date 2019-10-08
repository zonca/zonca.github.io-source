Title: Setup two factor authentication for UCSD, and Lastpass
Date: 2018-12-12 18:00
Author: Andrea Zonca
Tags: security, ucsd
Slug: twofactor-auth-ucsd

Starting at the end of January 2019 UCSD requires every employee to have activated
two factor authentication.

Go over to <https://duo-registration.ucsd.edu> to register your devices and
<https://twostep.ucsd.edu> to read more details.

Here some suggestions after I have used this for a few months.

The most convenient option is definitely to have the Duo application installed on
your phone, so that once you try to login it sends a notification to your phone,
you click accept and you're done.

Second best is to use the Duo or the Google Authenticator app to generate codes,
then you can copy those codes into the login form, and this is anyway useful for
VPN access, you choose the "2 Steps secured - allthroughucsd" option, type your
password followed by a comma and the code, otherwise just the password and get a
push notification on your primary device.


Then you can just add a mobile number and receive a text or add a landline and
receive a call.

I also recommend to buy a security key and add it as a authentication option
at <https://duo-registration.ucsd.edu>, either [Google Titan](https://store.google.com/product/titan_security_key_kit) or a [Yubico key](https://www.yubico.com/products/yubikey-hardware/) (I have a Titan), you can
keep it always with you so that if you don't have your phone or the phone battery
is dead, you can plug the security key in your USB port on the laptop and click on
its button to authenticate.

Anther option is to request a fob token, a device that generates and displays timed codes and that
is independent of a phone, see [instructions on the UCSD website](https://blink.ucsd.edu/technology/security/services/two-step-login/guide.html#token). They say there are only a limited number available and you need
to be prepared to justify why you are requesting one.

## Other services

Now that you already have Duo installed on your phone, I recommend to also activate
two factor auth on all other services:

* XSEDE
* NERSC
* Google
* Github
* Amazon
* Microsoft
* Dropbox

Consider that most of them just request the second step verification if you are on
a new device, so you need to do the verification just once in a while and it provides
a lot of security. Many of those also support the security key.

## Password handling with Lastpass

**Update October 2019**: Fed up of using Lastpass, their interface is clunky and slow, both in Chrome and Android, I switched to [Bitwarden](https://bitwarden.com). Way better, it also allows sharing with another user, only downside is that the do not offer Duo push 2FA for free, you need premium, but still supports using Duo as a token generator.

As you are into security, just go all the way and also install a password manager.
UCSD provides free enterprise accounts for all employees, see [the details](https://blink.ucsd.edu/technology/security/services/lastpass/index.html).

With Lastpass, you just remember 1 strong password to descrypt all of your other passwords.
If you ever used the Google Chrome builtin password manager, this is way way better.

You install the Lastpass extension on your browsers and the Lastpass app on your phone.

The only issue with Lastpass is that by default the Lastpass app on the smartphone automatically
logsout every 30 minutes or so, so you have to re-authenticate very often. This is due to UCSD
having configured it too strictly. I recommend to have a personal account and save all of the passwords
in the personal account and then link it from the Enterprise account.
Now from the desktop/laptop browsers you can use your Enterprise account, from the smartphone app instead
use the personal account.

You can also automatically import your Google Chrome passwords into Lastpass.

Now you have no excuse to re-use the same password, automatically generate a 20 char random password and save it in Lastpass.

### Save one-time codes

When you activate two factor auth on Google/Github and many other services, they also give you some one-time codes that you can use to login to the service if you do not have access to your phone, you can save them as "Notes" into the related account inside Lastpass.

### Activate 2 factor auth for Lastpass

You should also activate 2 factor auth in Lastpass, it also supports Duo so the configuration is similar to the configuration for UCSD. Only issue is that they do not support a security key here, so you can only add your smartphone.
