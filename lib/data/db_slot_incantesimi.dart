// lib/data/db_slot_incantesimi.dart

class SlotIncantesimi {
  final String classe;
  final Map<int, List<int>> slotPerLivello;
  final Map<int, int> trucchettiConosciuti;

  SlotIncantesimi({
    required this.classe,
    required this.slotPerLivello,
    required this.trucchettiConosciuti,
  });
}

final List<SlotIncantesimi> slotIncantesimiList = [
  SlotIncantesimi(
    classe: "Mago",
    slotPerLivello: {
      1: [2, 0, 0, 0, 0, 0, 0, 0, 0],
      2: [3, 0, 0, 0, 0, 0, 0, 0, 0],
      3: [4, 2, 0, 0, 0, 0, 0, 0, 0],
      4: [4, 3, 0, 0, 0, 0, 0, 0, 0],
      5: [4, 3, 2, 0, 0, 0, 0, 0, 0],
      6: [4, 3, 3, 0, 0, 0, 0, 0, 0],
      7: [4, 3, 3, 1, 0, 0, 0, 0, 0],
      8: [4, 3, 3, 2, 0, 0, 0, 0, 0],
      9: [4, 3, 3, 3, 1, 0, 0, 0, 0],
      10: [4, 3, 3, 3, 2, 0, 0, 0, 0],
      11: [4, 3, 3, 3, 2, 1, 0, 0, 0],
      12: [4, 3, 3, 3, 2, 1, 0, 0, 0],
      13: [4, 3, 3, 3, 2, 1, 1, 0, 0],
      14: [4, 3, 3, 3, 2, 1, 1, 0, 0],
      15: [4, 3, 3, 3, 2, 1, 1, 1, 0],
      16: [4, 3, 3, 3, 2, 1, 1, 1, 0],
      17: [4, 3, 3, 3, 2, 1, 1, 1, 1],
      18: [4, 3, 3, 3, 3, 1, 1, 1, 1],
      19: [4, 3, 3, 3, 3, 2, 1, 1, 1],
      20: [4, 3, 3, 3, 3, 2, 2, 1, 1],
    },
    trucchettiConosciuti: {
      1: 3,
      4: 4,
      10: 5
    },
  ),
  SlotIncantesimi(
    classe: "Warlock",
    slotPerLivello: {
      1: [1, 0, 0, 0, 0, 0, 0, 0, 0],
      2: [2, 0, 0, 0, 0, 0, 0, 0, 0],
      3: [2, 0, 0, 0, 0, 0, 0, 0, 0],
      4: [2, 0, 0, 0, 0, 0, 0, 0, 0],
      5: [2, 0, 0, 0, 0, 0, 0, 0, 0],
      6: [2, 0, 0, 0, 0, 0, 0, 0, 0],
      7: [2, 0, 0, 0, 0, 0, 0, 0, 0],
      8: [2, 0, 0, 0, 0, 0, 0, 0, 0],
      9: [2, 0, 0, 0, 0, 0, 0, 0, 0],
      10: [2, 0, 0, 0, 0, 0, 0, 0, 0],
      11: [3, 0, 0, 0, 0, 0, 0, 0, 0],
      12: [3, 0, 0, 0, 0, 0, 0, 0, 0],
      13: [3, 0, 0, 0, 0, 0, 0, 0, 0],
      14: [3, 0, 0, 0, 0, 0, 0, 0, 0],
      15: [3, 0, 0, 0, 0, 0, 0, 0, 0],
      16: [3, 0, 0, 0, 0, 0, 0, 0, 0],
      17: [4, 0, 0, 0, 0, 0, 0, 0, 0],
      18: [4, 0, 0, 0, 0, 0, 0, 0, 0],
      19: [4, 0, 0, 0, 0, 0, 0, 0, 0],
      20: [4, 0, 0, 0, 0, 0, 0, 0, 0],
    },
    trucchettiConosciuti: {
      1: 2,
      2: 2,
      3: 2,
      4: 3,
      10: 4
    },
  ),
SlotIncantesimi(
    classe: "Chierico",
    slotPerLivello: {
      for (int i = 1; i <= 20; i++)
        i: [
          i >= 1 ? 2 : 0,
          i >= 3 ? (i >= 4 ? 3 : 2) : 0,
          i >= 5 ? (i >= 6 ? 3 : 2) : 0,
          i >= 7 ? (i >= 8 ? 2 : 1) : 0,
          i >= 9 ? (i >= 10 ? 2 : 1) : 0,
          i >= 11 ? (i >= 13 ? 2 : 1) : 0,
          i >= 13 ? (i >= 15 ? 2 : 1) : 0,
          i >= 15 ? (i >= 17 ? 2 : 1) : 0,
          i >= 17 ? (i >= 19 ? 2 : 1) : 0,
        ]
    },
    trucchettiConosciuti: {
      1: 3,
      4: 4,
      10: 5
    },
  ),
  SlotIncantesimi(
    classe: "Druido",
    slotPerLivello: {
      for (int i = 1; i <= 20; i++)
        i: [
          i >= 1 ? 2 : 0,
          i >= 3 ? (i >= 4 ? 3 : 2) : 0,
          i >= 5 ? (i >= 6 ? 3 : 2) : 0,
          i >= 7 ? (i >= 8 ? 2 : 1) : 0,
          i >= 9 ? (i >= 10 ? 2 : 1) : 0,
          i >= 11 ? (i >= 13 ? 2 : 1) : 0,
          i >= 13 ? (i >= 15 ? 2 : 1) : 0,
          i >= 15 ? (i >= 17 ? 2 : 1) : 0,
          i >= 17 ? (i >= 19 ? 2 : 1) : 0,
        ]
    },
    trucchettiConosciuti: {
      1: 2,
      4: 3,
      10: 4
    },
  ),
  SlotIncantesimi(
    classe: "Bardo",
    slotPerLivello: {
      1: [2, 0, 0, 0, 0, 0, 0, 0, 0],
      2: [3, 0, 0, 0, 0, 0, 0, 0, 0],
      3: [4, 2, 0, 0, 0, 0, 0, 0, 0],
      4: [4, 3, 0, 0, 0, 0, 0, 0, 0],
      5: [4, 3, 2, 0, 0, 0, 0, 0, 0],
      6: [4, 3, 3, 0, 0, 0, 0, 0, 0],
      7: [4, 3, 3, 1, 0, 0, 0, 0, 0],
      8: [4, 3, 3, 2, 0, 0, 0, 0, 0],
      9: [4, 3, 3, 3, 1, 0, 0, 0, 0],
      10: [4, 3, 3, 3, 2, 0, 0, 0, 0],
      11: [4, 3, 3, 3, 2, 1, 0, 0, 0],
      12: [4, 3, 3, 3, 2, 1, 0, 0, 0],
      13: [4, 3, 3, 3, 2, 1, 1, 0, 0],
      14: [4, 3, 3, 3, 2, 1, 1, 0, 0],
      15: [4, 3, 3, 3, 2, 1, 1, 1, 0],
      16: [4, 3, 3, 3, 2, 1, 1, 1, 0],
      17: [4, 3, 3, 3, 2, 1, 1, 1, 1],
      18: [4, 3, 3, 3, 3, 1, 1, 1, 1],
      19: [4, 3, 3, 3, 3, 2, 1, 1, 1],
      20: [4, 3, 3, 3, 3, 2, 2, 1, 1],
    },
    trucchettiConosciuti: {
      1: 2,
      4: 3,
      10: 4
    },
  ),
  SlotIncantesimi(
    classe: "Stregone",
    slotPerLivello: {
      1: [2, 0, 0, 0, 0, 0, 0, 0, 0],
      2: [3, 0, 0, 0, 0, 0, 0, 0, 0],
      3: [4, 2, 0, 0, 0, 0, 0, 0, 0],
      4: [4, 3, 0, 0, 0, 0, 0, 0, 0],
      5: [4, 3, 2, 0, 0, 0, 0, 0, 0],
      6: [4, 3, 3, 0, 0, 0, 0, 0, 0],
      7: [4, 3, 3, 1, 0, 0, 0, 0, 0],
      8: [4, 3, 3, 2, 0, 0, 0, 0, 0],
      9: [4, 3, 3, 3, 1, 0, 0, 0, 0],
      10: [4, 3, 3, 3, 2, 0, 0, 0, 0],
      11: [4, 3, 3, 3, 2, 1, 0, 0, 0],
      12: [4, 3, 3, 3, 2, 1, 0, 0, 0],
      13: [4, 3, 3, 3, 2, 1, 1, 0, 0],
      14: [4, 3, 3, 3, 2, 1, 1, 0, 0],
      15: [4, 3, 3, 3, 2, 1, 1, 1, 0],
      16: [4, 3, 3, 3, 2, 1, 1, 1, 0],
      17: [4, 3, 3, 3, 2, 1, 1, 1, 1],
      18: [4, 3, 3, 3, 3, 1, 1, 1, 1],
      19: [4, 3, 3, 3, 3, 2, 1, 1, 1],
      20: [4, 3, 3, 3, 3, 2, 2, 1, 1],
    },
    trucchettiConosciuti: {
      1: 4,
      4: 5,
      10: 6
    },
  ),
  SlotIncantesimi(
    classe: "Paladino",
    slotPerLivello: {
      1: [0, 0, 0, 0, 0, 0, 0, 0, 0],
      2: [2, 0, 0, 0, 0, 0, 0, 0, 0],
      3: [3, 0, 0, 0, 0, 0, 0, 0, 0],
      4: [3, 0, 0, 0, 0, 0, 0, 0, 0],
      5: [4, 2, 0, 0, 0, 0, 0, 0, 0],
      6: [4, 2, 0, 0, 0, 0, 0, 0, 0],
      7: [4, 3, 0, 0, 0, 0, 0, 0, 0],
      8: [4, 3, 0, 0, 0, 0, 0, 0, 0],
      9: [4, 3, 2, 0, 0, 0, 0, 0, 0],
      10: [4, 3, 2, 0, 0, 0, 0, 0, 0],
      11: [4, 3, 3, 0, 0, 0, 0, 0, 0],
      12: [4, 3, 3, 0, 0, 0, 0, 0, 0],
      13: [4, 3, 3, 1, 0, 0, 0, 0, 0],
      14: [4, 3, 3, 1, 0, 0, 0, 0, 0],
      15: [4, 3, 3, 2, 0, 0, 0, 0, 0],
      16: [4, 3, 3, 2, 0, 0, 0, 0, 0],
      17: [4, 3, 3, 3, 1, 0, 0, 0, 0],
      18: [4, 3, 3, 3, 1, 0, 0, 0, 0],
      19: [4, 3, 3, 3, 2, 0, 0, 0, 0],
      20: [4, 3, 3, 3, 2, 0, 0, 0, 0],
    },
    trucchettiConosciuti: {},
  ),
  SlotIncantesimi(
    classe: "Ranger",
    slotPerLivello: {
      1: [0, 0, 0, 0, 0, 0, 0, 0, 0],
      2: [2, 0, 0, 0, 0, 0, 0, 0, 0],
      3: [3, 0, 0, 0, 0, 0, 0, 0, 0],
      4: [3, 0, 0, 0, 0, 0, 0, 0, 0],
      5: [4, 2, 0, 0, 0, 0, 0, 0, 0],
      6: [4, 2, 0, 0, 0, 0, 0, 0, 0],
      7: [4, 3, 0, 0, 0, 0, 0, 0, 0],
      8: [4, 3, 0, 0, 0, 0, 0, 0, 0],
      9: [4, 3, 2, 0, 0, 0, 0, 0, 0],
      10: [4, 3, 2, 0, 0, 0, 0, 0, 0],
      11: [4, 3, 3, 0, 0, 0, 0, 0, 0],
      12: [4, 3, 3, 0, 0, 0, 0, 0, 0],
      13: [4, 3, 3, 1, 0, 0, 0, 0, 0],
      14: [4, 3, 3, 1, 0, 0, 0, 0, 0],
      15: [4, 3, 3, 2, 0, 0, 0, 0, 0],
      16: [4, 3, 3, 2, 0, 0, 0, 0, 0],
      17: [4, 3, 3, 3, 1, 0, 0, 0, 0],
      18: [4, 3, 3, 3, 1, 0, 0, 0, 0],
      19: [4, 3, 3, 3, 2, 0, 0, 0, 0],
      20: [4, 3, 3, 3, 2, 0, 0, 0, 0],
    },
    trucchettiConosciuti: {},
  ),
];


