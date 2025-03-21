# Klypse Intro
![license][license-image]
![version][version-image]

[version-image]: https://img.shields.io/badge/version-0.1.0-blue.svg?style=flat
[license-image]: https://img.shields.io/badge/license-MIT-blue.svg?style=flat

##  What is Code?

[Code](https://getcode.com) is a mobile app that leverages self custodial 
blockchain technology to deliver a seamless payments experience that is instant, 
global, and private. 

## Development
The codebase is split into the following packages:

* [api](https://github.com/code-payments/code-pennypost/tree/main/packages/api) - The binary network protocol between the frontend and backend
* [database](https://github.com/code-payments/code-pennypost/tree/main/packages/database) - The database schema, models, and queries
* [backend](https://github.com/code-payments/code-pennypost/tree/main/packages/backend) - The glue between the database, the Code SDK, and the frontend
* [frontend](https://github.com/code-payments/code-pennypost/tree/main/packages/frontend) - The UI/UX components live here

## Quick Start

To run this locally, you will need to have the following dependencies:

* [Docker](https://docs.docker.com/get-docker/)
* [Node.js](https://nodejs.org/en/download/)
* [Bun.js](https://bun.sh/)
* [Sharp](https://sharp.pixelplumbing.com/install) (no manual steps should be required here for most people, the codebase will install this automatically)

Additionally, you will need a postgres database running somewhere. You can use
the following command to start a postgres database using docker:

```bash
docker run --name my-postgres -e POSTGRES_PASSWORD=mysecretpassword -p 5432:5432 -d postgres
```

Before you run the project, you will need to create a `.env` file in the
`backend` directory. You can copy the
[example.env](https://github.com/code-payments/code-pennypost/blob/main/packages/backend/example.env)
file and fill in the necessary values.

```bash
cp backend/example.env backend/.env
```

To run this app, use the following commands:

```bash
make install
make dev
```

## Deployment

To deploy this app, you will need to compile the frontend assets and optionally
build a docker image containing everything. You can do all of this by running
the following command:

```bash
make build
```

Then you can run the docker image you've just created using the following
command:

```bash
make run-local
```

Additionally, you'll need your own `verifier key`. This is a private key value.
This key is used to sign the payment requests that are sent to the Code
services. It allows us to verify that you actually own the domain name from
where the request is coming from. 

This codebase ships with the `example-getcode.com` verifier key. You should
replace this key with your own key once you have a domain name and have the
ability to host a json file at
`https://example.com/.well-known/code-payments.json`. This codebase will
automatically do this for you. 

**Important:** The `https` is required for security reasons, so make sure you have
an SSL certificate installed on your server. Additionally, subdomains are not
supported.

You can generate a `verifier key` by running the following command:

```bash
make verifier-key
```

## Getting Help

If you have any questions or need help integrating Code into your website or
application, please reach out to us on [Discord](https://discord.gg/T8Tpj8DBFp)
or [Twitter](https://twitter.com/getcode).

##  Contributing

For now the best way to contribute is to share feedback on
[Discord](https://discord.gg/T8Tpj8DBFp). This will evolve as we continue to
build out the platform and open up more ways to contribute. 

# Klypse.io 🌟

Welcome to Klypse - where creativity meets cosmic rewards in a minimalist, ad-free social stage. We're building a revolutionary platform that puts creators first, powered by $KIN and real-time connections.

## 🌌 What is Klypse?

Klypse is a Progressive Web App (PWA) that redefines social media by:
- Eliminating ads and algorithms
- Embracing raw creativity and cosmic flair
- Fostering genuine connections
- Rewarding creators instantly with $KIN
- Maintaining full anonymity

## 🎯 Core Features

### 📝 Posting Mechanics
- **One Free Post/Day**: Share your story with a 30-second video or 320-character text + one image
- **16-Hour Ephemerality**: Posts vanish after 16 hours, creating natural FOMO
- **Comment System**: 
  - Comments last 1 hour unless liked
  - Each like extends comment life by 2 hours (max 16 hours)
  - One comment per post per user
- **Countdown Pulse**: Watch the cosmic timer as posts near expiration

### 🔍 Discovery
- **Random Tab**: 
  - Vertical scroll with "cosmic pulse" animations
  - Like ($0.05 $KIN), tip, or follow ($1 $KIN)
  - 100% random, no repeats until refresh
- **Live Top 50 Tab**: Real-time leaderboard of top $KIN earners (refreshes every minute)
- **Rising Stars Tab**: Top 50 posts from users with < $10 $KIN lifetime

### 🔐 Anonymity & Authentication
- **Code Wallet Login**: 1-tap Solana-based signup with $KIN
- **Full Anonymity**: No personal data required
- **Guest Mode**: View tabs without interaction until Code wallet is required

### 👤 Cosmic Avatars & Profiles
- **Unique Designs**: 
  - Free base avatar at signup
  - Premium animated options ($KIN unlocks)
  - Avatar contests with $KIN prizes
- **Flippable Profile Card**:
  - Front: Avatar, nickname, followers, $KIN earned, Top 50 hits
  - Back: "Chat on FlipChat!" + QR code

### 💫 $KIN Integration & Monetization
- **Subscription**: $2/year unlocks all features (ad-free for all)
- **Transaction Fees**:
  - Likes: $0.05 $KIN (100% to creator, $0.01 Code wallet fee)
  - Tips: Preset $0.25, $0.50, $1 via Code wallet
  - Follows: $1 $KIN (100% to followed user)
- **Premium Posts**:
  - 1st: Free
  - 2nd: $0.25 (2x Random Tab boost)
  - 3rd: $0.50 (4x boost)
  - 4th: $1 (8x boost)
  - New User Bonus: 3 free Premium posts

### 🔄 Revive Feature
- **Trigger**: Post earns > $1 $KIN
- **Creator Revive**: 
  - First 15 hours
  - Pay 25% of $KIN earned (min $0.25, max $5)
- **Open Revive**: 
  - Final hour
  - Anyone can pay creator 25%
  - Winner owns the post
- **Effect**: +16 hours; new $KIN to reviver

### 🎮 Daily AI Challenge
- Daily prompt (e.g., "16-sec cosmic rant")
- Top 3 by $KIN earned win:
  - 1 free Premium post each
  - 24-hour pin in Random Tab
- Challenge Tab shows:
  - Live prompt
  - Yesterday's winners
  - Previous prompts and results

## 🚀 Future Growth

At 25,000 daily active users, we'll scale our model:
- Subscription: $5/year
- Likes: $0.10
- Follows: $2
- Premium posts: $1/$2/$5
- Revive trigger: $2 $KIN

## 🌟 Why Klypse?

- **Legal Safety**: 16-hour ephemerality + AI moderation
- **Code Benefits**: 1-tap login, minimal fees, privacy-first
- **Monetization**: Ad-free, subscription model, $KIN micropayments
- **Viral Potential**: Live leaderboards, Revive auctions, X integration

Join us in creating a new era of social media where creativity reigns supreme and creators are truly valued. 🌌