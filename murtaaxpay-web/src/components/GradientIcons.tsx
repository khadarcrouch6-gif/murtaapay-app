"use client";

import React from 'react';

export default function GradientIcons() {
  return (
    <svg width="0" height="0" className="absolute pointer-events-none -z-50 opacity-0" aria-hidden="true">
      <defs>
        {/* Emerald/Green Gradient - for Success, Growth, Security */}
        <linearGradient id="emerald-gradient" x1="0%" y1="0%" x2="100%" y2="100%">
          <stop offset="0%" stopColor="#34d399" />
          <stop offset="100%" stopColor="#059669" />
        </linearGradient>

        {/* Blue Gradient - for Trust, Balance, Professionalism */}
        <linearGradient id="blue-gradient" x1="0%" y1="0%" x2="100%" y2="100%">
          <stop offset="0%" stopColor="#60a5fa" />
          <stop offset="100%" stopColor="#2563eb" />
        </linearGradient>

        {/* Indigo/Purple Gradient - for Integration, Tech, Future */}
        <linearGradient id="indigo-gradient" x1="0%" y1="0%" x2="100%" y2="100%">
          <stop offset="0%" stopColor="#818cf8" />
          <stop offset="100%" stopColor="#4f46e5" />
        </linearGradient>

        {/* Amber/Orange Gradient - for Investments, Alerts, Energy */}
        <linearGradient id="amber-gradient" x1="0%" y1="0%" x2="100%" y2="100%">
          <stop offset="0%" stopColor="#fbbf24" />
          <stop offset="100%" stopColor="#d97706" />
        </linearGradient>

        {/* Rose/Red Gradient - for Sadaqah, Critical, Passion */}
        <linearGradient id="rose-gradient" x1="0%" y1="0%" x2="100%" y2="100%">
          <stop offset="0%" stopColor="#fb7185" />
          <stop offset="100%" stopColor="#e11d48" />
        </linearGradient>

        {/* Cyan/Teal Gradient - for Modern/Fresh DNA */}
        <linearGradient id="cyan-gradient" x1="0%" y1="0%" x2="100%" y2="100%">
          <stop offset="0%" stopColor="#22d3ee" />
          <stop offset="100%" stopColor="#0891b2" />
        </linearGradient>
      </defs>
    </svg>
  );
}
