# BSBikeRental

AL razširitev za Microsoft Dynamics 365 Business Central, ki podpira proces izposoje koles. V rešitvi je implementiranih vseh 8 faz opisanih v [AL_PROGRAMIRANJE_NALOGA.pdf](AL_PROGRAMIRANJE_NALOGA.pdf).

## Okolje

Projekt je bil razvit in preizkušen z Business Central različico 28 in AL runtime 17.0. Ob koncu razvoja posamezne faze sem tudi testiral delovanje dodane kode. Ker imam na svojem računalniku nameščen Windows 11 Home, ki ne podpira Hyper-V virtualizacije in poganjanja Windows Docker Containerjev, sem si Docker v katerem sem poganjal Business Central postavil na Azure VM virtualnem Windows strežniku. Konfiguriral sem ga tako, da sem do Docker containerja lahko dostopal iz VSCode okolja na svojem lokalnem računalniku in normalno poganjal aplikacijo

Podatki, ki sem jih vnesel v Business Central niso del repozitorija. Za izdelavo prodajnega računa mora v ciljnem podjetju obstajati standardni artikel "RENTAL" z mersko enoto "DAY".

## Implementacija

- evidenca tipov izposoje in koles,
- ceniki z obdobji veljavnosti,
- izposoje z vrsticami, izračunom zneskov in omejitvijo aktivnih izposoj kupca,
- začetek izposoje, vračilo koles in spremembe statusov,
- izdelava standardnega prodajnega računa,
- razširitev kartice kupca,
- analiza izposoj s Query objektom,
- poročili z Word in RDLC postavitvijo,
- API za branje podatkov o kolesih,
- XMLport za uvoz koles.

Razmislek o nadaljnjem razvoju je predstavljen v [FAZA8.md](FAZA8.md).
