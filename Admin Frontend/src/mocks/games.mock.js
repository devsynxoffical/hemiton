// ============================================================
// Hemi Ton Admin Portal — Canonical 10-Game Catalog Data (JavaScript)
// Aligned with Hemi Ton Mobile Game Center Design Kit & Audio Party Rooms
// ============================================================

export const MOCK_GAMES = [
  {
    id: 'fishing_star',
    name: 'Fishing Star',
    type: 'Arcade',
    status: 'active',
    entryFee: 10,
    minPrize: 12,
    maxPrize: 2000,
    totalRounds: 452000,
    totalPaidOut: 415840,
    houseEdge: 8.0,
    expectedReturn: 0.92,
    specificationStatus: 'ACTIVE_ENGINE',
    image: 'https://images.unsplash.com/photo-1544551763-46a013bb70d5?auto=format&fit=crop&w=600&h=350&q=80',
    createdAt: '2025-01-01T00:00:00Z',
    description: 'Dynamic deep-sea arcade fishing where players target virtual fish with configurable coin tiers and multi-level cannons.',
    outcomes: [
      { id: 'out-fs-1', name: 'Missed Shot', probability: 35, payout: 0, active: true },
      { id: 'out-fs-2', name: 'Clownfish (1.2x)', probability: 40, payout: 1.2, active: true },
      { id: 'out-fs-3', name: 'Swordfish (2.5x)', probability: 18, payout: 2.5, active: true },
      { id: 'out-fs-4', name: 'Hammerhead Shark (5x)', probability: 5, payout: 5.0, active: true },
      { id: 'out-fs-5', name: 'Golden Dragon Whale (20x)', probability: 2, payout: 20.0, active: true }
    ],
    history: [
      {
        version: 'v2.1',
        effectiveDate: '2026-06-01T00:00:00Z',
        operator: 'Hemi Ton Game Ops',
        reason: 'Adjusted Golden Dragon Whale spawn frequency',
        expectedReturn: 0.92,
        houseEdge: 8.0,
        outcomesCount: 5
      }
    ],
    config: { fishTiers: 5, cannonLevels: 7, energyCap: 20 }
  },
  {
    id: 'football_shootout',
    name: 'Football Shootout',
    type: 'Sports / Arcade',
    status: 'active',
    entryFee: 20,
    minPrize: 0,
    maxPrize: 5000,
    totalRounds: 388000,
    totalPaidOut: 364720,
    houseEdge: 6.0,
    expectedReturn: 0.94,
    specificationStatus: 'ACTIVE_ENGINE',
    image: 'https://images.unsplash.com/photo-1508098682722-e99c43a406b2?auto=format&fit=crop&w=600&h=350&q=80',
    createdAt: '2025-02-01T00:00:00Z',
    description: 'Fast-paced penalty kick shootout. Aim at top corners, outwit the goalkeeper AI, and build multiplier streaks.',
    outcomes: [
      { id: 'out-fb-1', name: 'Crossbar / Goalkeeper Save', probability: 40, payout: 0, active: true },
      { id: 'out-fb-2', name: 'Clean Goal (1.5x)', probability: 42, payout: 1.5, active: true },
      { id: 'out-fb-3', name: 'Top Corner Striker (3x)', probability: 13, payout: 3.0, active: true },
      { id: 'out-fb-4', name: 'Golden Boot Hat-Trick (10x)', probability: 5, payout: 10.0, active: true }
    ],
    history: [
      {
        version: 'v2.0',
        effectiveDate: '2026-05-15T00:00:00Z',
        operator: 'Sports Engine Team',
        reason: 'Added dynamic wind physics and streak bonuses',
        expectedReturn: 0.94,
        houseEdge: 6.0,
        outcomesCount: 4
      }
    ],
    config: { keeperSpeed: 'Dynamic', streakCap: 5 }
  },
  {
    id: 'fruit_match',
    name: 'Fruit Match',
    type: 'Slots / Match',
    status: 'active',
    entryFee: 15,
    minPrize: 0,
    maxPrize: 7500,
    totalRounds: 512000,
    totalPaidOut: 486400,
    houseEdge: 5.0,
    expectedReturn: 0.95,
    specificationStatus: 'ACTIVE_ENGINE',
    image: 'https://images.unsplash.com/photo-1619566636858-adf3ef46400b?auto=format&fit=crop&w=600&h=350&q=80',
    createdAt: '2025-03-01T00:00:00Z',
    description: 'Juicy 3-in-a-row cascading fruit match game with sweet combo multipliers and mystery coin drops.',
    outcomes: [
      { id: 'out-fm-1', name: 'No Match Combo', probability: 45, payout: 0, active: true },
      { id: 'out-fm-2', name: 'Watermelon Triple (1.5x)', probability: 35, payout: 1.5, active: true },
      { id: 'out-fm-3', name: 'Golden Pineapple Blast (4x)', probability: 15, payout: 4.0, active: true },
      { id: 'out-fm-4', name: 'Rainbow Fruit Fiesta (20x)', probability: 5, payout: 20.0, active: true }
    ],
    history: [
      {
        version: 'v1.8',
        effectiveDate: '2026-04-10T00:00:00Z',
        operator: 'Minigame Balancing',
        reason: 'Enhanced cascade audio effects and RTP tuning',
        expectedReturn: 0.95,
        houseEdge: 5.0,
        outcomesCount: 4
      }
    ],
    config: { boardSize: '6x6', cascadeRounds: 4 }
  },
  {
    id: 'rocket_challenge',
    name: 'Rocket Challenge',
    type: 'Crash / Multiplier',
    status: 'active',
    entryFee: 10,
    minPrize: 0,
    maxPrize: 50000,
    totalRounds: 890000,
    totalPaidOut: 854400,
    houseEdge: 4.0,
    expectedReturn: 0.96,
    specificationStatus: 'ACTIVE_ENGINE',
    image: 'https://images.unsplash.com/photo-1517976487502-d5952f4477c7?auto=format&fit=crop&w=600&h=350&q=80',
    createdAt: '2025-01-15T00:00:00Z',
    description: 'Server-authoritative rocket crash game where multiplier climbs in real-time until sudden engine explosion. Cash out before it pops!',
    outcomes: [
      { id: 'out-rkt-1', name: 'Early Crash (0x)', probability: 38, payout: 0, active: true },
      { id: 'out-rkt-2', name: 'Low Altitude Cashout (1.5x)', probability: 42, payout: 1.5, active: true },
      { id: 'out-rkt-3', name: 'Stratosphere Flight (3x)', probability: 14, payout: 3.0, active: true },
      { id: 'out-rkt-4', name: 'Moon Launch Jackpot (12x)', probability: 6, payout: 12.0, active: true }
    ],
    history: [
      {
        version: 'v3.0',
        effectiveDate: '2026-07-01T00:00:00Z',
        operator: 'Provably Fair Security',
        reason: 'HMAC-SHA256 client seed verification upgrade',
        expectedReturn: 0.96,
        houseEdge: 4.0,
        outcomesCount: 4
      }
    ],
    config: { maxMultiplier: 2500, tickRateMs: 80, provablyFair: true }
  },
  {
    id: 'lion_adventure',
    name: 'Lion Adventure',
    type: 'Arcade',
    status: 'active',
    entryFee: 15,
    minPrize: 0,
    maxPrize: 4500,
    totalRounds: 295000,
    totalPaidOut: 277300,
    houseEdge: 6.0,
    expectedReturn: 0.94,
    specificationStatus: 'ACTIVE_ENGINE',
    image: 'https://images.unsplash.com/photo-1534188753412-3e26d0d618d6?auto=format&fit=crop&w=600&h=350&q=80',
    createdAt: '2025-03-20T00:00:00Z',
    description: 'Savannah jungle platform runner. Leap over obstacles, collect golden meat treats, and trigger the Lion King frenzy mode.',
    outcomes: [
      { id: 'out-la-1', name: 'Stumble / Pitfall', probability: 42, payout: 0, active: true },
      { id: 'out-la-2', name: 'Gazelle Chase (1.6x)', probability: 40, payout: 1.6, active: true },
      { id: 'out-la-3', name: 'Pride Victory (3.5x)', probability: 13, payout: 3.5, active: true },
      { id: 'out-la-4', name: 'Golden Crown Roar (10x)', probability: 5, payout: 10.0, active: true }
    ],
    history: [
      {
        version: 'v1.4',
        effectiveDate: '2026-06-12T00:00:00Z',
        operator: 'Game Balancing',
        reason: 'Refined energy sheet recharge timers',
        expectedReturn: 0.94,
        houseEdge: 6.0,
        outcomesCount: 4
      }
    ],
    config: { dailyEnergyPills: 5, speedScale: 1.2 }
  },
  {
    id: 'seven_puzzle',
    name: 'Seven Puzzle',
    type: 'Slots / Match',
    status: 'active',
    entryFee: 25,
    minPrize: 0,
    maxPrize: 10000,
    totalRounds: 340000,
    totalPaidOut: 323000,
    houseEdge: 5.0,
    expectedReturn: 0.95,
    specificationStatus: 'ACTIVE_ENGINE',
    image: 'https://images.unsplash.com/photo-1518609878373-06d740f60d8b?auto=format&fit=crop&w=600&h=350&q=80',
    createdAt: '2025-02-10T00:00:00Z',
    description: 'Strategic numbers and lucky 777 matching puzzle. Slide tiles into combination lines to claim platform jackpots.',
    outcomes: [
      { id: 'out-sp-1', name: 'Grid Lockout', probability: 48, payout: 0, active: true },
      { id: 'out-sp-2', name: 'Single 7 Pair (1.8x)', probability: 35, payout: 1.8, active: true },
      { id: 'out-sp-3', name: 'Triple 7 Line (4x)', probability: 13, payout: 4.0, active: true },
      { id: 'out-sp-4', name: 'Lucky 777 Mega Vault (20x)', probability: 4, payout: 20.0, active: true }
    ],
    history: [
      {
        version: 'v1.5',
        effectiveDate: '2026-05-01T00:00:00Z',
        operator: 'Hemi Ton Studio',
        reason: 'Adjusted golden grid tile odds',
        expectedReturn: 0.95,
        houseEdge: 5.0,
        outcomesCount: 4
      }
    ],
    config: { gridDimension: '4x4', undoLimit: 2 }
  },
  {
    id: 'ludo_party',
    name: 'Ludo Party',
    type: 'Arcade',
    status: 'active',
    entryFee: 50,
    minPrize: 80,
    maxPrize: 180,
    totalRounds: 620000,
    totalPaidOut: 589000,
    houseEdge: 5.0,
    expectedReturn: 0.95,
    specificationStatus: 'ACTIVE_ENGINE',
    image: 'https://images.unsplash.com/photo-1610890716171-6b1bb98ffd09?auto=format&fit=crop&w=600&h=350&q=80',
    createdAt: '2025-01-20T00:00:00Z',
    description: 'Real-time 4-player social audio party board game. Roll dice with friends in voice rooms, capture pawns, and win the pot.',
    outcomes: [
      { id: 'out-lp-1', name: '4th Place Finish', probability: 25, payout: 0, active: true },
      { id: 'out-lp-2', name: '3rd Place Runner-Up', probability: 25, payout: 0.2, active: true },
      { id: 'out-lp-3', name: '2nd Place Silver (0.8x)', probability: 25, payout: 0.8, active: true },
      { id: 'out-lp-4', name: '1st Place Champion (2.8x)', probability: 25, payout: 2.8, active: true }
    ],
    history: [
      {
        version: 'v2.2',
        effectiveDate: '2026-07-10T00:00:00Z',
        operator: 'Voice Party Team',
        reason: 'Added room audience cheer bonuses',
        expectedReturn: 0.95,
        houseEdge: 5.0,
        outcomesCount: 4
      }
    ],
    config: { maxPlayers: 4, timerSeconds: 15, voiceSync: true }
  },
  {
    id: 'greedy_wheel',
    name: 'Greedy Wheel',
    type: 'Multiplier',
    status: 'active',
    entryFee: 10,
    minPrize: 0,
    maxPrize: 25000,
    totalRounds: 740000,
    totalPaidOut: 688200,
    houseEdge: 7.0,
    expectedReturn: 0.93,
    specificationStatus: 'ACTIVE_ENGINE',
    image: 'https://images.unsplash.com/photo-1596838132731-3301c3fd4317?auto=format&fit=crop&w=600&h=350&q=80',
    createdAt: '2025-02-14T00:00:00Z',
    description: 'Carnival spinning prize wheel with multiple color segments: 2x Silver, 5x Gold, 10x Ruby, and 50x Dragon Jackpot.',
    outcomes: [
      { id: 'out-gw-1', name: 'Blank Spin (0x)', probability: 51, payout: 0, active: true },
      { id: 'out-gw-2', name: 'Silver Wedge (2x)', probability: 35, payout: 2.0, active: true },
      { id: 'out-gw-3', name: 'Gold Wedge (5x)', probability: 10, payout: 5.0, active: true },
      { id: 'out-gw-4', name: 'Dragon Crown (25x)', probability: 4, payout: 25.0, active: true }
    ],
    history: [
      {
        version: 'v1.9',
        effectiveDate: '2026-06-25T00:00:00Z',
        operator: 'Hemi Ton Math Lab',
        reason: 'Standardized sector distribution',
        expectedReturn: 0.93,
        houseEdge: 7.0,
        outcomesCount: 4
      }
    ],
    config: { segments: 24, spinDurationSeconds: 4 }
  },
  {
    id: 'roulette',
    name: 'European Roulette',
    type: 'Table Game',
    status: 'active',
    entryFee: 10,
    minPrize: 0,
    maxPrize: 36000,
    totalRounds: 520000,
    totalPaidOut: 505960,
    houseEdge: 2.7,
    expectedReturn: 0.973,
    specificationStatus: 'ACTIVE_ENGINE',
    image: 'https://images.unsplash.com/photo-1518609878373-06d740f60d8b?auto=format&fit=crop&w=600&h=350&q=80',
    createdAt: '2025-01-01T00:00:00Z',
    description: 'Authentic 37-pocket European roulette wheel with straight-up, split, color, column, and dozen wager distributions.',
    outcomes: [
      { id: 'out-rou-1', name: 'No Bet Match', probability: 51.35, payout: 0, active: true },
      { id: 'out-rou-2', name: 'Red / Black / Even / Odd (2x)', probability: 45.95, payout: 2.0, active: true },
      { id: 'out-rou-3', name: 'Straight Up Number (36x)', probability: 2.7, payout: 36.0, active: true }
    ],
    history: [
      {
        version: 'v1.0',
        effectiveDate: '2025-01-01T00:00:00Z',
        operator: 'Casino Architecture Team',
        reason: 'Single zero European wheel rules release',
        expectedReturn: 0.973,
        houseEdge: 2.7,
        outcomesCount: 3
      }
    ],
    config: { pockets: 37, zeroType: 'Single Zero', trackWagers: true }
  },
  {
    id: 'pk_arena',
    name: 'PK Arena Battles',
    type: 'Multiplier',
    status: 'active',
    entryFee: 50,
    minPrize: 0,
    maxPrize: 25000,
    totalRounds: 410000,
    totalPaidOut: 389500,
    houseEdge: 5.0,
    expectedReturn: 0.95,
    specificationStatus: 'ACTIVE_ENGINE',
    image: 'https://images.unsplash.com/photo-1542751371-adc38448a05e?auto=format&fit=crop&w=600&h=350&q=80',
    createdAt: '2025-03-01T00:00:00Z',
    description: 'Host-versus-Host 1v1 live voice duel. Viewers send combo gifts to boost their champion host’s battle gauge.',
    outcomes: [
      { id: 'out-pk-1', name: 'Defeat', probability: 48, payout: 0, active: true },
      { id: 'out-pk-2', name: 'Audience Cheer Bonus (1.5x)', probability: 36, payout: 1.5, active: true },
      { id: 'out-pk-3', name: 'Dominant PK Victory (3x)', probability: 12, payout: 3.0, active: true },
      { id: 'out-pk-4', name: 'Grand MVP Dragon Strike (10x)', probability: 4, payout: 10.0, active: true }
    ],
    history: [
      {
        version: 'v2.5',
        effectiveDate: '2026-07-15T00:00:00Z',
        operator: 'Live PK Ops',
        reason: 'Added sudden death overtime multipliers',
        expectedReturn: 0.95,
        houseEdge: 5.0,
        outcomesCount: 4
      }
    ],
    config: { battleDurationSeconds: 180, suddenDeath: true }
  }
];

export const GAME_STATUSES = ['all', 'active', 'paused', 'inactive'];
export const GAME_TYPES = ['All', 'Arcade', 'Sports / Arcade', 'Slots / Match', 'Crash / Multiplier', 'Multiplier', 'Table Game'];
