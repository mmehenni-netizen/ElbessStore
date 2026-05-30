require('dotenv').config();

const sendVerificationEmail = async (email, token) => {
    const clientUrl = process.env.CLIENT_URL || 'https://elbessstore.onrender.com';
    const verificationUrl = `${clientUrl}/verify-email?token=${token}`;

    try {
        const response = await fetch("https://api.brevo.com/v3/smtp/email", {
            method: "POST",
            headers: {
                "Content-Type": "application/json",
                "api-key": process.env.BREVO_API_KEY,
            },
            body: JSON.stringify({
                sender: { name: "Coffee Shop", email: "mm.regouat@gmail.com" },
                to: [{ email: email }],
                subject: "Verify Your Email Address - Coffee Shop",
                htmlContent: `
                    <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
                        <h2 style="color: #333;">Welcome to Coffee Shop!</h2>
                        <p>Please verify your email address by clicking the link below:</p>
                        <a href="${verificationUrl}" 
                           style="display: inline-block; padding: 10px 20px; background-color: #4CAF50; color: white; text-decoration: none; border-radius: 5px;">
                           Verify Email
                        </a>
                        <p>Or copy and paste this link: ${verificationUrl}</p>
                    </div>
                `
            }),
        });

        if (!response.ok) {
            const err = await response.json();
            console.error("Brevo error:", err);
            return false;
        }

        console.log("Email sent successfully ✅");
        return true;

    } catch (error) {
        console.error("Error sending email:", error);
        return false;
    }
};

module.exports = { sendVerificationEmail };