# AccessWork – Inclusive Job Platform

AccessWork is a mobile-first job platform designed to help disabled and chronically ill individuals find remote and flexible employment opportunities that genuinely accommodate their needs.

The app focuses on **skills, flexibility, and accessibility**, rather than medical labels or traditional CV barriers.

---

## 🎯 Problem

Many disabled people struggle to find employment not because of a lack of skill, but because:

* Job listings don’t specify real accommodations
* Hiring processes are inaccessible
* Disclosure of disability is risky
* Platforms focus on traditional CVs rather than actual ability

AccessWork aims to solve this by creating a **skills-first, accessibility-aware job platform**.

---

## 🚀 MVP Goals

The first version of the app focuses on one core function:

> Connect disabled job seekers in South Africa with remote or flexible jobs that will accommodate them.

### Core Features

* Job seeker profiles based on **skills**, not medical information
* Functional needs selection (e.g. flexible hours, remote work)
* Accessibility-aware job listings
* One-tap job applications
* Mobile-first, low-friction design

---

## 👥 Target Users

### Primary

* Disabled or chronically ill professionals
* People needing remote or flexible work
* South African job seekers

### Secondary (later)

* Employers looking to hire inclusively
* Neurodivergent professionals
* Hearing or visually impaired users

---

## 🛠 Tech Stack

**Frontend:**

* Flutter (Dart)

**Backend:**

* Firebase Authentication
* Cloud Firestore

**Development Tools:**

* VS Code
* Android Studio (emulator)

---

## 📱 Planned Screens (MVP)

1. Splash / Welcome screen
2. Sign up / Login
3. Profile setup (skills + needs)
4. Job listings
5. Job detail
6. Apply confirmation

---

## 🧩 Core Data Models

### User

* id
* email
* role (job seeker / employer)
* skills[]
* work preferences
* functional needs[]

### Job

* id
* employer_id
* title
* description
* remote (true/false)
* flexible_hours (true/false)
* accessibility features[]

### Application

* user_id
* job_id
* status

---

## ♿ Accessibility Principles

* High-contrast UI
* Large tap targets
* Minimal steps per task
* Plain, simple language
* No forced disability disclosure
* Designed for low cognitive load

---

## 💰 Monetisation (Future)

* Free for job seekers
* Employer subscription to post jobs
* Optional placement fees
* Enterprise accessibility hiring tools

---

## 📍 Initial Market

* South Africa
* Remote and flexible roles only

---

## 📅 Development Roadmap

### Phase 1

* Basic Flutter app
* Authentication
* Profile setup
* Job browsing

### Phase 2

* Real job postings
* Employer onboarding
* Application tracking

### Phase 3

* Employer ratings
* Accessibility verification
* Payment integration

---

## 🧑‍💻 Developer

Solo-built as a mobile-first accessibility project focused on real-world employment barriers.

---

## 📜 License

To be decided.
