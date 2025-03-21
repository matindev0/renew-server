#!/bin/bash

# دڵنیابە لەوەی کە هەموو پاکەتە پێویستەکان دامەزراون
if ! command -v node &> /dev/null
then
    echo "Node.js نییە، تکایە دامەزرێنە!"
    exit
fi

if ! command -v npm &> /dev/null
then
    echo "npm نییە، تکایە دامەزرێنە!"
    exit
fi

# دڵنیابە لەوەی کە هەموو پاکەتە پێویستەکان دامەزراون
npm install puppeteer 2captcha dotenv

# کۆدەکەت لەناو فایلێکی JavaScript بنووسە
cat > renew_server.js <<EOF
const puppeteer = require('puppeteer');
const solver = require('2captcha');
require('dotenv').config();

const LOGIN_URL = "https://mcserverhost.com/login";
const SERVER_URL = "https://www.mcserverhost.com/servers/33c2f94b/dashboard";
const siteKey = "6Ld8G_wqAAAAACPRnT_KXxReAU0AdkMbUZ-9mqP_"; 

async function solveCaptcha(page) {
    console.log("🟡 Solving CAPTCHA...");
    const result = await solver.solveRecaptchaV2(process.env.CAPTCHA_API_KEY, siteKey, LOGIN_URL);

    await page.evaluate(token => {
        document.querySelector("#g-recaptcha-response").innerHTML = token;
    }, result);

    console.log("✅ CAPTCHA Solved!");
}

async function loginAndRenew() {
    const browser = await puppeteer.launch({ headless: false });
    const page = await browser.newPage();
    
    console.log("🔵 Opening login page...");
    await page.goto(LOGIN_URL, { waitUntil: "networkidle2" });

    await page.type('input[name="username"]', "matindev");
    await page.type('input[name="password"]', "Matinnajat1762003$$");

    await solveCaptcha(page);  // تێپەڕینی CAPTCHA

    await page.click("button[type=submit]");
    await page.waitForNavigation();

    console.log("✅ Logged in successfully!");

    while (true) {
        await page.goto(SERVER_URL, { waitUntil: "networkidle2" });
        console.log("🟢 Checking Renew Button...");

        const renewButton = await page.$("button:has-text('RENEW')");
        if (renewButton) {
            await renewButton.click();
            console.log("✅ Server Renewed!");
        } else {
            console.log("⚠️ No Renew Button Found!");
        }

        console.log("⏳ Waiting 30 seconds...");
        await new Promise(r => setTimeout(r, 30000));  // 30 چرکە چوونە ناوەوە
    }
}

loginAndRenew();
EOF

# فایلەکە جێبەجێ بکە
node renew_server.js
