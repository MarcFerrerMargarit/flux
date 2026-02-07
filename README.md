# Flux ⚡

**The All-in-One Management Platform for Health & Sports Professionals.**

![Status](https://img.shields.io/badge/status-Pre--Seed-orange)
![Flutter](https://img.shields.io/badge/Flutter-3.19+-02569B?logo=flutter)
![Supabase](https://img.shields.io/badge/Supabase-PostgreSQL-3ECF8E?logo=supabase)
![License](https://img.shields.io/badge/license-Proprietary-blue)

---

## 📋 Overview

**Flux** is a SaaS (Software as a Service) solution designed to digitize and simplify management for small and medium-sized businesses in the physical health and sports sector (Physiotherapists, Personal Trainers, Yoga Studios, and Boutique Gyms).

Unlike fragmented solutions (Excel + WhatsApp + Google Calendar), Flux offers a unified **Multi-Tenant** platform that synchronizes the professional's agenda with the client's experience in real-time.

### Key Features
* **Hybrid Scheduling:** Seamlessly manages 1-on-1 appointments (Physio) and Group Classes (Gyms) in a single calendar.
* **Smart Credits System:** Automated management of session packs/bonuses. No more manual counting on paper.
* **Client Portal:** A dedicated mobile experience for end-users to book, cancel, and track their progress.
* **Financial Control:** Real-time tracking of debts, payments, and revenue per service.

---

## 🏗 Architecture & Tech Stack

Flux follows a **Cloud-Native**, **Cross-Platform** architecture designed for scalability and low maintenance costs.

### Frontend (Mobile & Web App)
* **Framework:** Flutter (Dart).
* **Target:** iOS, Android, and Web (SPA) from a single codebase.
* **State Management:** Riverpod / BLoC.
* **Architecture:** Clean Architecture (Data -> Domain -> Presentation).

### Backend (BaaS)
* **Platform:** Supabase.
* **Database:** PostgreSQL with Row Level Security (RLS) for strict multi-tenancy.
* **Auth:** Supabase Auth (JWT).
* **Storage:** Supabase Storage (Medical reports, profile pictures).

### Landing Page
* **Framework:** Astro + Tailwind CSS.
* **Deployment:** Vercel / Netlify.

### Payments
* **Provider:** Stripe Connect.

---

## 📂 Project Structure

This repository follows a Monorepo approach to keep all contexts unified.

```bash
flux/
├── apps/
│   ├── flux_app/          # Main Flutter Application (Admin & Client)
│   └── flux_landing/      # Astro Marketing Website
├── packages/              # Shared Dart packages (UI Kit, Core logic)
├── supabase/              # SQL migrations and Edge Functions
├── docs/                  # Project documentation and assets
└── README.md              # Project entry point