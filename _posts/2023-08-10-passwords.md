---
layout : post
title : Let's Expire Password Expiry
category : social
image: "/seo/2023-08-10.png"
---

Too many organizations employ outmoded policies related to passwords that have been shown to be ineffective in providing security, namely, the requirement to change a memorized token on a regular periodic basis. I would like to present here various references which demonstrate that the industry standards have evolved in the last decade and do not require users to change a memorized token on a regular basis. It is best practice to require a changed password when credentials are found in other systems (I know of some orgs that use the [haveibeenpwned API](https://haveibeenpwned.com/API/v3) to provide intelligence when credentials are found on the dark web) but expiry should not be required until there is evidence a compromise has occurred.

### Key paragraph from NIST Digital Identity Guidelines<sup>1</sup>

> Verifiers SHOULD NOT impose other composition rules (e.g., requiring mixtures of different character types or prohibiting consecutively repeated characters) for memorized secrets. Verifiers SHOULD NOT require memorized secrets to be changed arbitrarily (e.g., periodically). However, verifiers SHALL force a change if there is evidence of compromise of the authenticator.

### PCI DSS password requirements<sup>2</sup>

Requirements set in the Payment Card Industry Data Security Standards state that passwords should only be changed on a regular 90-day basis, if it is the only authentication method available (Section 8.3.9). A stronger security posture is to require multi-factor authentication to access secure systems.

### FTC persuasive article against mandatory password changes<sup>3</sup>

Lorrie Craner, Chief Technologist at FTC, wrote an article that makes the point of this blog post: mandatory password changes should be reconsidered. Compellingly, she details research that has demonstrated "[an] attacker who knows the previous password and has access to the hashed password file (generally because they stole it) and can carry out an offline attack can **guess the current password for 41% of accounts within 3 seconds per account (on a typical 2009 research computer)**. These results suggest that after a mandated password change, attackers who have previously learned a user’s password may be able to guess the user’s new password fairly easily."

### Three different Microsoft articles make the case

#### Microsoft Security removed password expiration in v1903 of Windows 10 and Windows Server<sup>4</sup>

> Periodic password expiration is a defense only against the probability that a password (or hash) will be stolen during its validity interval and will be used by an unauthorized entity. If a password is never stolen, there’s no need to expire it. And if you have evidence that a password has been stolen, you would presumably act immediately rather than wait for expiration to fix the problem.

#### Microsoft 365 password policy reccommendations<sup>5</sup>

> Password expiration requirements do more harm than good, because these requirements make users select predictable passwords, composed of sequential words and numbers that are closely related to each other. In these cases, the next password can be predicted based on the previous password. Password expiration requirements offer no containment benefits because cybercriminals almost always use credentials as soon as they compromise them.

#### Robyn Hicock, Microsoft Identity Protection Team<sup>6</sup>

In a research article, the Microsoft Identity Protection Team identifies password expiry as an "anti-pattern" (a practice which is believed to solve a problem but in fact does not).

> Password expiration policies do more harm than good, because these policies drive users to very predictable passwords composed of sequential words and numbers which are closely related to each other (that is, the next password can be predicted based on the previous password). Password change offers no containment benefits cyber criminals almost always use credentials as soon as they compromise them.

## Microsoft CISO says the future is passwordless<sup>7</sup>

> "I remember we had a motto to get MFA everywhere, in hindsight that was the right security goal but the wrong approach. Make this about the user outcome, so transition to "we want to eliminate passwords". But the words you use matter. It turned out that simple language shift changed the culture and the view of what we were trying to accomplish. More importantly, it changed our design and what we built, like Windows Hello for business," he says.
>
> "If I eliminate passwords and use any form of biometrics, it's much faster and the experience is so much better."

Microsoft is moving towards a hybrid mode of work and, to support that shift, it's making a push towards a Zero Trust network design, which assumes the network has been breached, that the network extends beyond the corporate firewall, and caters to BYOD devices that could be used at home for work or at work for personal communications. 

## References

[1] [NIST 800-63B Section 5.1.1.2 Memorized Secret Verifiers][NIST]

[NIST]:https://pages.nist.gov/800-63-3/sp800-63b.html#sec5

[2] [PCI-DSS 4.0 Section 8.3.9][PCIDSS]

[PCIDSS]:https://listings.pcisecuritystandards.org/documents/PCI-DSS-v4-0-SAQ-A.pdf 

[3] [FTC Time to rethink mandatory password changes][FTC]

[FTC]:https://www.ftc.gov/policy/advocacy-research/tech-at-ftc/2016/03/time-rethink-mandatory-password-changes 

[4] [Microsoft Security baseline (FINAL) for Windows 10 v1903 and Windows Server v1903][msoft-secguide]

[msoft-secguide]:https://learn.microsoft.com/en-us/archive/blogs/secguide/security-baseline-final-for-windows-10-v1903-and-windows-server-v1903

[5] [Microsoft Password policy recommendations for Microsoft 365 passwords][m365]

[m365]:https://learn.microsoft.com/en-us/microsoft-365/admin/misc/password-policy-recommendations?view=o365-worldwide#password-expiration-requirements-for-users

[6] [Microsoft Password Guidance][msoftpwd]

[msoftpwd]:https://www.microsoft.com/en-us/research/wp-content/uploads/2016/06/Microsoft_Password_Guidance-1.pdf

[7] [Microsoft's CISO: Why we're trying to banish passwords forever][msoftciso]

[msoftciso]:https://www.zdnet.com/article/microsofts-ciso-why-were-trying-to-banish-passwords-forever/