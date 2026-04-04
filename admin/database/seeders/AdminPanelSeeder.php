<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\FxRate;
use App\Models\FeeSetting;
use App\Models\FloatAccount;

class AdminPanelSeeder extends Seeder
{
    public function run(): void
    {
        // ── FX Rates ─────────────────────────────────────────
        FxRate::create([
            'currency_from'   => 'EUR',
            'currency_to'     => 'USD',
            'rate'            => 1.0850,
            'spread_percent'  => 1.50,
            'is_active'       => true,
            'source'          => 'manual',
        ]);

        FxRate::create([
            'currency_from'   => 'EUR',
            'currency_to'     => 'USD',
            'rate'            => 1.0790,
            'spread_percent'  => 2.00,
            'is_active'       => false,
            'source'          => 'api',
            'api_provider'    => 'exchangerate-api.com',
        ]);

        // ── Fee Settings ──────────────────────────────────────
        FeeSetting::create([
            'name'          => 'Standard EUR→USD Fee',
            'fee_type'      => 'percent',
            'fee_value'     => 1.50,
            'currency_from' => 'EUR',
            'currency_to'   => 'USD',
            'min_amount'    => 1000,    // €10 minimum
            'max_amount'    => null,
            'is_active'     => true,
            'description'   => 'Default 1.5% fee on all standard transfers.',
        ]);

        FeeSetting::create([
            'name'          => 'Small Transfer Flat Fee',
            'fee_type'      => 'fixed',
            'fee_value'     => 1.00,    // €1.00 flat
            'currency_from' => 'EUR',
            'currency_to'   => 'USD',
            'min_amount'    => 0,
            'max_amount'    => 999,     // under €10
            'is_active'     => true,
            'description'   => 'Flat €1 fee for transfers below €10.',
        ]);

        // ── Float Accounts ────────────────────────────────────
        FloatAccount::create([
            'name'               => 'Wallester Business EUR Account',
            'provider'           => 'wallester',
            'currency'           => 'EUR',
            'balance'            => 45000000,   // €450,000.00
            'alert_threshold'    => 5000000,    // Alert below €50,000
            'account_identifier' => 'WALL-EU-001',
            'is_active'          => true,
            'last_synced_at'     => now(),
        ]);

        FloatAccount::create([
            'name'               => 'WAAFI USD Float Account',
            'provider'           => 'waafi',
            'currency'           => 'USD',
            'balance'            => 3200000,    // $32,000.00  ← LOW!
            'alert_threshold'    => 5000000,    // Alert below $50,000
            'account_identifier' => '+252612345678',
            'is_active'          => true,
            'last_synced_at'     => now()->subHours(2),
        ]);

        FloatAccount::create([
            'name'               => 'E-Dahab USD Float',
            'provider'           => 'edahab',
            'currency'           => 'USD',
            'balance'            => 8750000,    // $87,500.00
            'alert_threshold'    => 2000000,
            'account_identifier' => '+252676543210',
            'is_active'          => true,
            'last_synced_at'     => now()->subHours(1),
        ]);

        $this->command->info('✅ Admin Panel seed data created successfully.');
        $this->command->info('   - 2 FX Rates (1 active EUR→USD @ 1.085)');
        $this->command->info('   - 2 Fee Settings (1.5% standard + €1 flat)');
        $this->command->info('   - 3 Float Accounts (Wallester EUR, WAAFI USD ⚠️, E-Dahab USD)');
    }
}
