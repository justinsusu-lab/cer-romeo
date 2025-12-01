import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class FAQPage extends StatefulWidget {
  const FAQPage({super.key});
  @override
  State<FAQPage> createState() => _FAQPageState();
}

class _FAQPageState extends State<FAQPage> {
  final TextEditingController _searchCtl = TextEditingController();
  final ValueNotifier<bool?> _expandAll = ValueNotifier<bool?>(null);

  @override
  void dispose() {
    _searchCtl.dispose();
    _expandAll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Build all FAQ tiles once and filter by query
    final allFaqs = <FaqTile>[
      FaqTile(
        title: 'Cosa sono le CER',
        controller: _expandAll,
        body: const [
          Text(
            'Le CER (Comunità Energetiche Rinnovabili) sono la nuova forma di promozione della produzione di energia elettrica da fonti rinnovabili (fotovoltaico-eolico-idroelettrico-biomasse) che gli stati membri della comunità europea si sono impegnati a realizzare.',
            style: TextStyle(color: Colors.black87),
          ),
          SizedBox(height: 8),
          Text(
            'Grazie a questa direttiva, normata sul territorio nazionale (Scopri quadro normativo), un insieme di utenti (imprese, cittadini, enti pubblici, enti religiosi, enti del terzo settore, …) tramite la volontaria adesione ad un soggetto di diritto autonomo (la CER in forma di associazione, cooperativa, fondazione o altra forma NON a scopo di lucro) si pongono l’obiettivo di produrre, consumare e gestire l’energia elettrica rinnovabile sfruttando il principio della condivisione / sharing energetico.',
            style: TextStyle(color: Colors.black87),
          ),
          SizedBox(height: 8),
          Text(
            'Sull’autoconsumo virtuale (in ogni ora, il minimo tra la somma dell’energia elettrica effettivamente immessa dagli impianti di produzione e la somma dell’energia elettrica prelevata per il tramite dei punti di connessione) vengono definiti una serie di incentivi economici garantiti per 20 anni dalla data di costituzione con un importante ritorno economico ambientale e sociale per la comunità stessa!',
            style: TextStyle(color: Colors.black87),
          ),
          SizedBox(height: 8),
          Text(
            'Questo rende possibile:',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          SizedBox(height: 6),
          _Bullet(text: 'Una riduzione dell’impatto ambientale;'),
          _Bullet(text: 'Un risparmio sui costi energetici;'),
          _Bullet(
            text:
                'Un contenimento dei tempi di rientro di un investimento in impianti di produzione a fonte rinnovabile;',
          ),
        ],
      ),
      FaqTile(
        title:
            "Riferimenti normativi e stato dell'arte della CER e delle altre forme di condivisione dell'energia rinnovabile",
        controller: _expandAll,
        body: const [
          Text(
            '1. Milleproroghe del febbraio 2020: l’Italia anticipa il recepimento della Direttiva RED II e regola nell’articolo 42-bis la costituzione di CER (Comunità Energetiche Rinnovabili) e GAC (Gruppi di Autoconsumatori Collettivi) nel limite della cabina di trasformazione da Media in Bassa tensione e con impianti aventi potenza di picco non superiore a 200 kW.',
            style: TextStyle(color: Colors.black87),
          ),
          SizedBox(height: 8),
          Text(
            '2. Decreto Legislativo n. 199 dell’8 novembre, in vigore dal 15 dicembre 2021: reca disposizioni in materia di energia da fonti rinnovabili, e definisce strumenti, meccanismi, incentivi e quadro istituzionale, finanziario e giuridico per CER e GAC nel limite della cabina di trasformazione da Alta in Media tensione e con impianti aventi potenza di picco non superiore a 1 MW. (Scarica il testo del Decreto Legislativo n.199)',
            style: TextStyle(color: Colors.black87),
          ),
          SizedBox(height: 8),
          Text(
            '3. ARERA, delibera del 27 dicembre 2022 n. 727/2022/R/EEL: emana il TIAD (Testo Integrato dell’Autoconsumo Diffuso) con applicazione prevista entro il 1° marzo 2023, in concomitanza con l’entrata in vigore del decreto MASE e con gli strumenti di incentivazione economica. Regola le 7 forme di condivisione dell’energia. (Scarica il TIAD)',
            style: TextStyle(color: Colors.black87),
          ),
          SizedBox(height: 8),
          Text(
            '4. 23 gennaio 2024: il MASE pubblica in via definitiva il decreto attuativo per le Comunità energetiche rinnovabili e l’autoconsumo diffuso in Italia. (Scarica il decreto approvato)',
            style: TextStyle(color: Colors.black87),
          ),
          SizedBox(height: 10),
          Text(
            'Dettagli principali:',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          SizedBox(height: 6),
          _Bullet(
            text:
                '1) Potenza massima agevolabile in progetti di CER/AUC: 5 GW entro il 31 dicembre 2027.',
          ),
          _Bullet(
            text:
                '2) Contributo a fondo perduto pari al 40% della spesa per CER in comuni sotto i 5.000 abitanti: risorse fino a 2,2 miliardi di euro, 2 GW entro il 30 giugno 2026.',
          ),
          _Bullet(
            text: '3) Molto altro nel decreto… (Scarica il decreto approvato).',
          ),
        ],
      ),
      FaqTile(
        title: 'Chi può partecipare ad una CER',
        controller: _expandAll,
        body: const [
          Text(
            'STRUTTURE PUBBLICHE',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          SizedBox(height: 4),
          Text(
            'Comuni ed enti di territorio che abbiano la necessità di realizzare significativi abbattimenti dei costi delle forniture per le utenze pubbliche o che intendano realizzare progetti di efficientamento e razionalizzazione degli apparati per i servizi ai cittadini (illuminazione pubblica, sistemi di rifornimento per la mobilità elettrica, ecc…).',
            style: TextStyle(color: Colors.black87),
          ),
          SizedBox(height: 10),
          Text(
            'CONSUMATORI DOMESTICI E COMMERCIALI',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          SizedBox(height: 4),
          Text(
            'Consumatori (domestici e commerciali) che intendono ottenere un risparmio, derivante dall’autoconsumo virtuale di energia rinnovabile prodotta dalla Comunità Energetica.',
            style: TextStyle(color: Colors.black87),
          ),
          SizedBox(height: 10),
          Text(
            'PRODUTTORI DOMESTICI E COMMERCIALI',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          SizedBox(height: 4),
          Text(
            'Produttori (domestici e commerciali) che, oltre ad ottenere il risparmio grazie all’autoconsumo diretto, vogliano contribuire al costo dell’unità fotovoltaica da installare sul proprio tetto/lastrico per godere di una remunerazione certa del capitale investito.',
            style: TextStyle(color: Colors.black87),
          ),
          SizedBox(height: 10),
          Text(
            'INVESTITORI PUBBLICI O PRIVATI',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          SizedBox(height: 4),
          Text(
            'Aziende di territorio collegate alla CER che intendono investire nel progetto per ottenere una remunerazione certa del capitale e ridurre la propria carbon footprint.',
            style: TextStyle(color: Colors.black87),
          ),
        ],
      ),
      FaqTile(
        title: 'Quali sono le finalità di una CER',
        controller: _expandAll,
        body: const [
          Text('AMBIENTALE', style: TextStyle(fontWeight: FontWeight.w700)),
          SizedBox(height: 4),
          Text(
            'L’energia elettrica deve essere prodotta solo da fonti rinnovabili senza generare immissioni di CO2 in atmosfera.',
            style: TextStyle(color: Colors.black87),
          ),
          SizedBox(height: 8),
          Text('ECONOMICO', style: TextStyle(fontWeight: FontWeight.w700)),
          SizedBox(height: 4),
          Text(
            'L’autoconsumo individuale e l’incentivo sull’energia condivisa consente di ridurre i costi delle bollette elettriche.',
            style: TextStyle(color: Colors.black87),
          ),
          SizedBox(height: 8),
          Text('SOCIALE', style: TextStyle(fontWeight: FontWeight.w700)),
          SizedBox(height: 4),
          Text(
            'La CER consente di ridurre la povertà energetica e di generare valore sul territorio grazie alla redistribuzione dei ricavi derivanti dagli incentivi e dalla vendita in rete (RID).',
            style: TextStyle(color: Colors.black87),
          ),
        ],
      ),
      FaqTile(
        title: 'Quali sono le figure chiave di una CER',
        controller: _expandAll,
        body: const [
          Text('PROMOTORE', style: TextStyle(fontWeight: FontWeight.w700)),
          SizedBox(height: 4),
          Text(
            'Soggetto che promuove la realizzazione della CER.',
            style: TextStyle(color: Colors.black87),
          ),
          SizedBox(height: 8),
          Text('MEMBRI', style: TextStyle(fontWeight: FontWeight.w700)),
          SizedBox(height: 4),
          Text(
            'Soggetti che partecipano con i loro consumi elettrici o con la loro produzione di energia rinnovabile alla CER.',
            style: TextStyle(color: Colors.black87),
          ),
          SizedBox(height: 8),
          Text('PRODUTTORE', style: TextStyle(fontWeight: FontWeight.w700)),
          SizedBox(height: 4),
          Text(
            'Responsabile dell’esercizio dell’impianto/i di produzione di energia rinnovabile e messa a disposizione della CER anche a mezzo di un contratto di noleggio.',
            style: TextStyle(color: Colors.black87),
          ),
          SizedBox(height: 8),
          Text(
            'GESTORE E REFERENTE VERSO IL GSE',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          SizedBox(height: 4),
          Text(
            'Gestore della piattaforma cloud di aggregazione e gestione dei dati di consumo/produzione dei membri, dei rapporti con il GSE (ente che eroga gli incentivi) ed eventualmente di supporto tecnico degli impianti.',
            style: TextStyle(color: Colors.black87),
          ),
        ],
      ),
      FaqTile(
        title: 'Referente per le CER e Gruppi di Autoconsumo Collettivo',
        controller: _expandAll,
        body: const [
          _Bullet(
            text:
                '1) Nel caso di un gruppo di autoconsumatori di energia rinnovabile che agiscono collettivamente: il legale rappresentante dell’edificio o condominio ovvero un produttore di energia elettrica che gestisce uno o più impianti di produzione rilevanti nella configurazione di gruppo, ai fini del servizio di valorizzazione e incentivazione dell’energia elettrica condivisa.',
          ),
          _Bullet(
            text:
                '2) Nel caso di una comunità di energia rinnovabile: è la comunità stessa.',
          ),
        ],
      ),
      FaqTile(
        title: 'Come si costituisce una CER',
        controller: _expandAll,
        body: const [
          Text(
            'Per prima cosa è necessario individuare le aree dove realizzare gli impianti alimentati da fonti rinnovabili e gli utenti con cui associarsi e condividere l’energia elettrica.',
            style: TextStyle(color: Colors.black87),
          ),
          SizedBox(height: 8),
          Text(
            'È poi necessario costituire legalmente la CER, sotto forma di associazione, ente del terzo settore, cooperativa, cooperativa benefit, consorzio, organizzazione senza scopo di lucro, dotando la CER di autonomia giuridica con atto costitutivo e statuto.',
            style: TextStyle(color: Colors.black87),
          ),
          SizedBox(height: 8),
          Text(
            'L’adesione alla CER di un consumatore o di un produttore di energia rinnovabile può avvenire in fase di costituzione o successivamente, secondo le modalità previste dagli atti e dagli statuti.',
            style: TextStyle(color: Colors.black87),
          ),
        ],
      ),
      FaqTile(
        title: 'Cosa sono le AUC o GAC',
        controller: _expandAll,
        body: const [
          Text(
            'Le AUC o GAC (Gruppi di Autoconsumatori Collettivi) sono utenti prosumer/consumer che sottostanno ad uno stesso tetto (es.: condomini, centri commerciali o super condomini).',
            style: TextStyle(color: Colors.black87),
          ),
          SizedBox(height: 8),
          Text(
            'È quindi un insieme di almeno due autoconsumatori che si associano per condividere l’energia elettrica prodotta da un impianto a fonte rinnovabile e che si trovano nello stesso edificio.',
            style: TextStyle(color: Colors.black87),
          ),
        ],
      ),
      FaqTile(
        title: 'Cosa è un autoconsumatore individuale a distanza',
        controller: _expandAll,
        body: const [
          Text(
            'Un autoconsumatore individuale “a distanza” è un cliente finale che produce e consuma energia elettrica rinnovabile per il proprio consumo utilizzando la rete di distribuzione.',
            style: TextStyle(color: Colors.black87),
          ),
          SizedBox(height: 8),
          Text(
            'È costituito da almeno due punti di connessione di cui uno che alimenti l’utenza di consumo intestata al cliente finale e un altro a cui è collegato un impianto di produzione.',
            style: TextStyle(color: Colors.black87),
          ),
        ],
      ),
      FaqTile(
        title:
            'Cosa si intende per impianto di produzione da energia rinnovabile detenuto dalla CER',
        controller: _expandAll,
        body: const [
          Text(
            'È un impianto di produzione di energia elettrica alimentato da fonti rinnovabili del quale la comunità di energia rinnovabile ha la proprietà ovvero la piena disponibilità sulla base di un titolo giuridico anche diverso dalla proprietà (quali, a titolo d’esempio, usufrutto, ovvero titoli contrattuali o altri titoli quali il comodato d’uso), a condizione che la mera detenzione o disponibilità dell’impianto sulla base di un titolo diverso dalla proprietà non sia di ostacolo al raggiungimento degli obiettivi della comunità.',
            style: TextStyle(color: Colors.black87),
          ),
        ],
      ),
      FaqTile(
        title: 'Chi è il produttore di energia elettrica',
        controller: _expandAll,
        body: const [
          Text(
            'È una persona fisica o giuridica che produce energia elettrica indipendentemente dalla proprietà dell’impianto di produzione. Egli è l’intestatario dell’officina elettrica di produzione, ove prevista dalla normativa vigente, nonché l’intestatario delle autorizzazioni alla realizzazione e all’esercizio dell’impianto di produzione.',
            style: TextStyle(color: Colors.black87),
          ),
        ],
      ),
      FaqTile(
        title: "Ritiro dedicato dell'energia immessa in rete",
        controller: _expandAll,
        body: const [
          Text(
            'Il Ritiro Dedicato da parte del GSE rappresenta una modalità semplificata a disposizione dei produttori di elettricità per il collocamento sul mercato dell’energia elettrica immessa in rete, alternativa alla vendita diretta in Borsa.',
            style: TextStyle(color: Colors.black87),
          ),
          SizedBox(height: 8),
          Text(
            'In pratica, il GSE funge da acquirente e intermediario tra il produttore e il mercato dell’energia, con il vantaggio di semplificare le procedure e offrendo, a determinate condizioni, una redditività più sicura rispetto ai prezzi che caratterizzano il mercato libero sulla Borsa, grazie a prezzi minimi garantiti.',
            style: TextStyle(color: Colors.black87),
          ),
          SizedBox(height: 8),
          Text(
            'Il prezzo di ritiro dell’energia elettrica da parte del GSE è definito dall’Autorità per l’Energia ed è pari al prezzo zonale orario, ossia il prezzo che si forma sul mercato elettrico che varia in base all’ora nella quale l’energia viene immessa in rete e alla zona di mercato in cui si trova l’impianto.',
            style: TextStyle(color: Colors.black87),
          ),
        ],
      ),
      FaqTile(
        title: 'Energia elettrica condivisa per autoconsumo virtuale',
        controller: _expandAll,
        body: const [
          Text(
            'L’energia condivisa per l’autoconsumo è definita, in ogni ora, come il minimo tra la somma dell’energia elettrica effettivamente immessa e la somma dell’energia elettrica prelevata per il tramite dei punti di connessione.',
            style: TextStyle(color: Colors.black87),
          ),
        ],
      ),
      FaqTile(
        title:
            'Chi aderisce ad una CER o un gruppo AUC ha dei vincoli sulla fornitura di energia elettrica?',
        controller: _expandAll,
        body: const [
          Text(
            'Tutti i partecipanti alla CER – consumatori finali o autoconsumatori – mantengono i loro diritti di clienti finali, compreso quello della scelta del fornitore di energia elettrica. Hanno inoltre la facoltà di uscire dalla Comunità quando lo desiderano, secondo le regole contenute nello statuto. Le stesse facoltà di ingresso e di uscita sono garantite ai produttori da fonte rinnovabile.',
            style: TextStyle(color: Colors.black87),
          ),
        ],
      ),
      FaqTile(
        title:
            'Quali sono gli incentivi statali previsti per la costituzione delle CER',
        controller: _expandAll,
        body: const [
          Text(
            'Per tutte le CER sono previsti incentivi sull’energia autoconsumata sotto due diverse forme:',
            style: TextStyle(color: Colors.black87),
          ),
          SizedBox(height: 6),
          _Bullet(
            text:
                '1) Tariffa incentivante sull’energia prodotta da FER e autoconsumata virtualmente dai membri della CER, riconosciuta dal GSE per 20 anni dalla data di entrata in esercizio di ciascun impianto FER.',
          ),
          _Bullet(
            text:
                '2) Corrispettivo di valorizzazione per l’energia autoconsumata, definito da ARERA (circa 8 €/MWh, valore soggetto ad aggiornamento).',
          ),
          SizedBox(height: 8),
          Text(
            'Inoltre, tutta l’energia elettrica rinnovabile prodotta ma non autoconsumata resta nella disponibilità dei produttori ed è valorizzata a condizioni di mercato. Per tale energia è possibile richiedere al GSE l’accesso al Ritiro Dedicato.',
            style: TextStyle(color: Colors.black87),
          ),
          SizedBox(height: 8),
          Text(
            'Per le sole CER con impianti ubicati in comuni con popolazione inferiore a 5.000 abitanti è previsto un contributo in conto capitale pari al 40% del costo dell’investimento (PNRR).',
            style: TextStyle(color: Colors.black87),
          ),
        ],
      ),
      FaqTile(
        title:
            'A quanto ammonta il corrispettivo di valorizzazione ARERA per l’energia condivisa',
        controller: _expandAll,
        body: const [
          Text(
            'Il GSE, per ciascuna CER, calcola il corrispettivo di valorizzazione ARERA in base alla quantità di energia elettrica autoconsumata. Il valore varia annualmente secondo le determinazioni di ARERA (nel 2023: 8,48 €/MWh).',
            style: TextStyle(color: Colors.black87),
          ),
        ],
      ),
      FaqTile(
        title:
            'È possibile cumulare la tariffa incentivante con il contributo PNRR o altri contributi in conto capitale?',
        controller: _expandAll,
        body: const [
          Text(
            'Sì. La tariffa incentivante è cumulabile con il contributo PNRR o altri contributi in conto capitale fino al 40%, con una decurtazione della tariffa incentivante del 50% (in modalità lineare).',
            style: TextStyle(color: Colors.black87),
          ),
          SizedBox(height: 8),
          Text(
            'Se un produttore ottenesse un contributo in conto capitale superiore al 40% del costo dell’investimento (sui massimali previsti), non sarebbe possibile ottenere la tariffa incentivante per l’energia elettrica prodotta dall’impianto in questione.',
            style: TextStyle(color: Colors.black87),
          ),
        ],
      ),
      FaqTile(
        title: 'Sono ammessi i sistemi di accumulo nelle CER?',
        controller: _expandAll,
        body: const [
          Text(
            'Sì. L’energia accumulata è considerata energia condivisa all’interno della CER e quindi incentivata.',
            style: TextStyle(color: Colors.black87),
          ),
        ],
      ),
      FaqTile(
        title:
            'Una colonnina per la ricarica di veicoli elettrici può appartenere a una CER?',
        controller: _expandAll,
        body: const [
          Text(
            'Sì. In una CER possono essere presenti anche infrastrutture di ricarica per veicoli elettrici e l’energia assorbita per la ricarica è considerata dal GSE ai fini del calcolo dell’energia condivisa.',
            style: TextStyle(color: Colors.black87),
          ),
        ],
      ),
    ];

    final q = _searchCtl.text.trim().toLowerCase();
    final filtered = q.isEmpty
        ? allFaqs
        : allFaqs.where((t) => t.title.toLowerCase().contains(q)).toList();

    // Costruisco la lista con spaziatura
    final tiles = <Widget>[];
    for (var i = 0; i < filtered.length; i++) {
      tiles.add(filtered[i]);
      if (i < filtered.length - 1) tiles.add(const SizedBox(height: 12));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Domande e risposte - FAQ')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header moderno con gradiente
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary.withOpacity(0.12),
                  Colors.white,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.black12),
            ),
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Icon(Icons.help_outline, color: Colors.black54),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Ad ogni domanda cerchiamo un risposta. Se all’interno di questa sezione FAQ non trovi quello che stai cercando puoi sempre\nInviare una mail a @romeogroup.it esponendo in modo chiaro la tua richiesta permettendoci così di analizzarla e darti una risposta',
                    style: TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Ricerca + azioni globali
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchCtl,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search),
                    hintText: 'Cerca tra le domande...',
                    isDense: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    suffixIcon: _searchCtl.text.isEmpty
                        ? null
                        : IconButton(
                            tooltip: 'Pulisci',
                            icon: const Icon(Icons.close),
                            onPressed: () {
                              _searchCtl.clear();
                              setState(() {});
                            },
                          ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: () => _expandAll.value = true,
                icon: const Icon(Icons.unfold_more),
                label: const Text('Espandi'),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: () => _expandAll.value = false,
                icon: const Icon(Icons.unfold_less),
                label: const Text('Comprimi'),
              ),
            ],
          ),

          const SizedBox(height: 12),
          ...tiles,
        ],
      ),
    );
  }
}

class FaqTile extends StatefulWidget {
  final String title;
  final List<Widget> body;
  final ValueListenable<bool?>? controller;
  const FaqTile({
    super.key,
    required this.title,
    required this.body,
    this.controller,
  });

  @override
  State<FaqTile> createState() => _FaqTileState();
}

class _FaqTileState extends State<FaqTile> {
  bool _open = false;
  void _onControllerChanged() {
    final v = widget.controller?.value;
    if (v != null && v != _open) setState(() => _open = v);
  }

  @override
  void initState() {
    super.initState();
    widget.controller?.addListener(_onControllerChanged);
  }

  @override
  void didUpdateWidget(covariant FaqTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?.removeListener(_onControllerChanged);
      widget.controller?.addListener(_onControllerChanged);
    }
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_onControllerChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          children: [
            InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => setState(() => _open = !_open),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.title,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                    AnimatedRotation(
                      turns: _open ? 0.25 : 0.0,
                      duration: const Duration(milliseconds: 180),
                      child: Icon(
                        _open ? Icons.remove : Icons.add,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            AnimatedCrossFade(
              crossFadeState: _open
                  ? CrossFadeState.showFirst
                  : CrossFadeState.showSecond,
              duration: const Duration(milliseconds: 200),
              firstChild: Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: widget.body,
                ),
              ),
              secondChild: const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}

class _Bullet extends StatelessWidget {
  final String text;
  const _Bullet({super.key, required this.text});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontSize: 14)),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }
}
