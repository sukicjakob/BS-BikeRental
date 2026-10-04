# FAZA 8 – Nadaljnji razvoj in optimizacija sistema

## Pet glavnih delov sistema

1. **Vodenje koles:** Pri večjem številu zapisov bi bilo smiselno dodati še ključe za "Status", "Rental Type Code" in lokacijo. Prav tako bi glede na to, da imamo podatek o tem ali je kolo na servisu, bilo smiselno dodati tudi samo zgodovino servisov. Tako uporabniki lahko vedno vidijo kakšno kolo dobijo in kdaj je bilo servisirano.

2. **Proces izposoje:** Poslovna logika aplikacije je v codeunitu "Rental Management". Pri večjem številu sočasnih uporabnikov bi bilo treba preverjanje razpoložljivosti in spremembo statusa kolesa izvesti znotraj ene transakcije in na ta način preprečiti, da bi lahko različni uporabniki sočasno dostopali do oz. si skušali izposoditi isto kolo.

3. **Ceniki:** Za hitrejše iskanje veljavne cene in preverjanje prekrivanja bi lahko dodali sestavljen ključ "Rental Type Code, Starting Date, Ending Date" in na ta način pohitrili poizvedbo za pridobitev podatkov.

4. **Analitika in poročila:** Pri večji količini podatkov bi bilo od uporabnikov smiselno zahtevati datumske filtre ter dodati ključe še na datum, status in samega kupca. Večja poročila bi bilo smiselno, da bi se ta izvajala samodejno v ozadju.

5. **Integracije:** API že omogoča branje podatkov, bi bilo pa verjetno smiselno prek API-ja podpreti še ostale operacije nad podatki (dodajanje, urejanje, brisanje), predvsem v primeru da bi rezervacije potekale prek neke nove zunanje aplikacije. Tako bi funkcionalnosti preprosto lahko povezali prek API klicev.

XMLport že preskoči neveljavne vrstice, bi pa v primeru neveljavnih uvozov bilo smiselno uporabniku javiti tudi, kaj je pri uvozu posamezne vrstice šlo narobe. Lahko bi dodali log zavrnjenih zapisov z razlogi, ter kdo in kdaj jih je poskušal vnesti.

## Ali bi sistem deloval z 10.000 ali več izposojami?
Deloval bi, vendar bi se s tem ko bi se količina podatkov večala, upočasnilo njegovo delovanje (štetje aktivnih izposoj, iskanje cen, FlowField za skupni znesek, poročila brez filtrov, ...). V ta namen bi lahko dodali dodatne ključe, ki ustrezajo najpogostejšim filtrom, in omejili analize le glede na podano obdobje, ki ga uporabnik vnese.

## Kje bi se pojavila ozka grla in kako bi jih izboljšal?
Ozka grla bi bila predvsem pogosto in ponavljajoče branje vrstic izposoje, štetje aktivnih izposoj posameznega kupca in iskanje veljavnega cenika. Uporabili bi lahko sestavljene ključe da čim bolj omejimo nabor podatkov, ki jih dejansko potrebujemo, skušali kar se da zmanjšati število ponovnih poizvedb kjer je to mogoče in sproti spremljati izvajanje z Business Central telemetrije in ustrezno ukrepati.

## Kako bi optimiziral izračune?
Znesek vrstice bi se še naprej izračunal samo ob spremembi dni, cene ali kolesa. Skupni znesek je FlowField, zato se ne shranjuje podvojen podatek. Če bi izračun pri velikem številu vrstic postal prepočasen, bi lahko dodali ustrezen ključ s "SumIndexFields".

## Kako bi sistem prilagodil drugim vrstam izposoje?
Trenutno implementacijo bi lahko naredili bolj generično, npr. "Bicycle" bi lahko preimenovali v recimo "Rental Item". Skupna logika cen, izposoje in vračila, ki se bi uporabljala tudi pri ostalih vrstah bi ostala v codeunitih, posebne lastnosti koles, oz. druge opreme pa bi bile v ustreznih povezanih tabelah/razširitvah.

## Kaj bi spremenil pri več kot 1.000 strankah?
Dodali bi lahko ključe za iskanje izposoj po kupcu in posameznem statusu ter pripravili različne poglede za izposoje glede na statuse (odprte, aktivne, zapadle in vrnjene). Omogočili bi dodatne filtre in uporabnikov zahtevali da jih vnesejo, namesto da so jim vedno privzeto prikazani vsi zapisi hkrati.

## Katere dodatne funkcionalnosti bi dodal?
Dodal bi rezervacije koles, zgodovino servisov za posamezna kolesa, stranki bi lahko poslali obvestila za zamujene vrnitve  ter  ob tem prikazali dodatne stroške zaradi zamude. Lahko bi dodali tudi možnost, da se v primeru ugotovitve poškodb na kolesu te stranki dodatno zaračunajo. Na glavo izposoje bi shranil tudi številko ustvarjenega prodajnega računa in tako preprečil večkratno fakturiranje iste izposoje, kar je v trenutni implementaciji mogoče.
