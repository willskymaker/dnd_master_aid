// lib/data/db_condizioni.dart
//
// Condizioni ufficiali di D&D 5e con una sintesi del loro effetto
// meccanico. Usate sia dalla scheda del personaggio salvato che dal
// tracker di combattimento.
const Map<String, String> condizioniD20 = {
  'Accecato':
      'Fallisce automaticamente le prove che richiedono la vista. I tiri per '
      'colpire contro di lui hanno vantaggio, i suoi hanno svantaggio.',
  'Affascinato':
      'Non può attaccare chi lo affascina né bersagliarlo con effetti '
      'dannosi. Chi lo affascina ha vantaggio nelle interazioni sociali.',
  'Assordato': 'Fallisce automaticamente le prove che richiedono l\'udito.',
  'Afferrato':
      'Velocità 0, non beneficia di bonus alla velocità. Finisce se chi '
      'afferra viene incapacitato o allontanato.',
  'Impaurito':
      'Svantaggio a prove e attacchi finché la fonte della paura è in '
      'vista; non può avvicinarsi volontariamente ad essa.',
  'Incapacitato': 'Non può compiere azioni né reazioni.',
  'Invisibile':
      'Impossibile da vedere senza mezzi speciali. I suoi attacchi hanno '
      'vantaggio, quelli contro di lui svantaggio.',
  'Paralizzato':
      'Incapacitato, non può muoversi né parlare. Fallisce automaticamente '
      'i TS su Forza e Destrezza. Gli attacchi contro di lui hanno '
      'vantaggio e sono critici se da 1,5 metri o meno.',
  'Pietrificato':
      'Trasformato in sostanza inanimata, incapacitato, non consapevole. '
      'Resistenza a tutti i danni.',
  'Avvelenato':
      'Svantaggio ai tiri per colpire e alle prove di caratteristica.',
  'Prono':
      'Svantaggio ai tiri per colpire. Gli attacchi in mischia contro di '
      'lui hanno vantaggio, quelli a distanza svantaggio.',
  'Trattenuto':
      'Velocità 0. Svantaggio ai tiri per colpire e ai TS su Destrezza. '
      'Gli attacchi contro di lui hanno vantaggio.',
  'Stordito':
      'Incapacitato, non può muoversi, parla a stento. Fallisce '
      'automaticamente i TS su Forza e Destrezza. Gli attacchi contro di '
      'lui hanno vantaggio.',
  'Esausto':
      'Livelli cumulativi di penalità (svantaggio a prove, velocità '
      'dimezzata, PF massimi ridotti, fino alla morte al livello 6).',
  'Incosciente':
      'Incapacitato, non consapevole, cade prono e lascia cadere ciò che '
      'tiene in mano. Fallisce automaticamente i TS su Forza e Destrezza. '
      'Gli attacchi contro di lui hanno vantaggio e sono critici se da 1,5 '
      'metri o meno.',
};
