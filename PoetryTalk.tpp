--author Clarissa Littler (left_adjoint)
--title Poetry in Partnership
--date today

--newpage

--heading Me and my talk

--center Me
* My background is in diff geo/particle physics/programming language design
* Worked for the last few years in education
* Computation ∩ Arts

--center This talk
* A little on poetry
* A little on things I tried
* The experience of partnership
* What else I want to do
* Lessons learned

--newpage
--heading The why and wherefore

I love writing poetry but I often feel stuck in creative ruts

Why not work on a procgen project to help me

* feel more creative
* think more about what makes poetry, poetry

--newpage 
--heading Not generated poetry, generated shapes

The goal isn't to generate poetry per-se but rather to generate the shapes of poetry that the authors writes themselves

--newpage
--heading Version 1

Observations:
* Limited scope: Only talking about poetry in english
* The base unit of (english) poetry structure is the syllable
* Poetry comes in a terrifying array of forms, anti-forms, styles, and philosophies
* Need not just one generator but a family of them
--newpage
--heading Version 1

Observations cont.:
* The simplest generator creates stanzas and chooses line lengths in syllables
* Unconstrained variation is too ugly
* Variation around a mean
--newpage
--heading Example: form

 ------: 6
 ---------: 9
 ------------: 12
 -----: 5
 ------: 6
 ----: 4
 ------: 6

 ---------: 9
 ------: 6
 -----: 5
 -------------: 13
 -----------: 11

--newpage
--heading Example:poem
Nihilism and the
End Times, we're all prophets of a dead
God damn we're empty in intention and becoming
more hollow by the
hour. I don't know when we
stopped believing
that we had a future but I---

I think too many are proud of seeing the
end at hand, of sneering
that they're not surprised
but when we survive 10000 years, humanity's
lease renewed birth by birth: who did you help live?

--newpage
--heading Example: form
Very first poem on project

 ---------: 9
 -----: 5
 ----: 4
 ------------: 12
 ---------: 9

 -----------------: 17
 -----------: 11
 -------------: 13
 ------------: 12
 -------------: 13
--newpage
--heading Example
Very first poem on project

If I had been in the Garden that
day and I'd seen Eve
before her first
bite. I would have grabbed on tight and I would have told
her "don't stop, no matter what he says"

Because we talk an awful lot about Eve's foolishness about her
sin, but we never talk about how scary
it had to be, terrifying it had to feel to
defy your god and only family you knew
to take a snake's word that it could be better than this

--newpage
--heading Version 2

Observations:
* This already produces something kinda okay!
* In only a few lines of code!
* It's enough to get the ol' bean working
* But it's a tiny sliver of what poetry can be

--newpage
--heading Version 2

What to change:
* Arbitrary functions of line and stanza number
* Generate random functions from pieces
* Can create waves, shapes, pictures

--newpage
--heading Example
Superposition of sine waves, randomly generated

8: --------
9: ---------
8: --------
7: -------
7: -------
10: ----------
12: ------------
13: -------------
12: ------------
9: ---------
7: -------
6: ------
6: ------
5: -----
3: ---
--newpage
2: --
2: --
2: --
4: ----
7: -------
8: --------
7: -------
6: ------
6: ------
7: -------
9: ---------
9: ---------
7: -------
6: ------

--newpage
--heading Example
I worship the moon and the stars,
I lose myself in the sacred void
that swims with endless energy
the infinitude: holy
beyond our comprehension.
I was taught to worship a righteous God,
a being of absolute power, wrath, envy
His jealously intertwined with his love-cruelty
He was a God who I tried to love, a father
I wanted to please and a distant
listener always holding
every thought captive
I was trapped and alone
I was emptied out
a vessel
--newpage
Nothing
Can grow
Nothing
Can build itself
back up because nothing is
really ever just nothing and
the vaccuum pulses with life
and the universe is
never empty but is
full of creation, breathing
in & out, rising, falling, being
Nothing is ever lost or wasted
and all the time I mourn is
endless fabric of space

--newpage
--heading Version 3 & 4: Modern poetry

First tried generating indentation as well.

Okay but not right!

Modern poetry treats the empty space as as much
a part of the line as the text itself

Generate text and space interleaved

Signals to generate space: >= 0 text, <0 space

--newpage
--heading Example
Forms get more interesting, representation gets harder

| |-|-| | | |-|-|-|-|-| |-|-|-| | | | 
| | | | | |-|-| | |-|-|-|-|-
| | |-|-| | | | |-|-|-| | | |-|-
|-|-|-| | |-|-|-| | | | | |-
| | |-|-|-|-|-| | | |-| | | | | |-

| |-|-|-| | | |-|-|-|-| |-|-|-|-| | | | 
|-| | | | | |-|-| |-|-|-|-|-|-| | | |-
| | | |-| | | | 
|-|-|-|-| |-|-|-| | | | 
| | |-|-|-|-|-| | | | |-| | | | |-|-|-| | 
| |-|-|-| | | |-|-|-|-|-| |-|-|-| | | | | 
|-| | | | | |-|-| | |-

| | | |-| | | | | |-|-|-| | | |-|-|-
|-|-|-|-| |-|-|-|-| | | | | |-|-| | |-|-
|-| | |-|-|-|-|-| | | |-| | | 
--newpage
--heading Version 5: Metre
Everything we've considered is free verse
Free verse has metre
just not prescribed metre

Most classical anglophonic forms are described in two-syllable feet:

spondee: strong-strong
pyrrhic: weak-weak
iamb: weak-strong
trochee: strong-weak

iambic pentameter: five iambs per line

--newpage
--heading Example: Form
|-*| | | | | |-*|--| | | |*-|*-|-*
| |-*|--|*-|*-|-*| |-*|*-|*-| | | 
| | | | | 

|-*|--|-*|-*| | | |-*|--| | | | |-*
| | | |-*|*-|*-| | | 

--newpage
--heading Example: Poem
The fall          of man.   this the      love/fear, our motiva-
  tion. I've been a woman---always? perhaps   but I haven't ever
____________

do you know who you are? will you      be assured when          they ask
        your name? Can you even ______  


--newpage
--heading Version 6: Rhyming

To this point I've neglected rhyme

Historically important, but less a part of modern prosody

Easiest approach: generate rhymes by random assignment

--newpage
--heading Example: Form

(2,5) c:   -----
(2,12) c:   ------------
(4,8) a:     --------
(0,10) b: ----------

(3,13) a:    -------------
(0,14) e: --------------
(2,11) a:   -----------

(2,12) c:   ------------
(3,11) d:    -----------

(3,9) c:    ---------
(2,10) b:   ----------
(2,10) c:   ----------
(2,9) c:   ---------
(3,13) c:    -------------
(2,6) a:   ------
(3,13) d:    -------------

--newpage
--heading Example: Form
Sometimes odd results

(5,11) a:      -----------
(5,11) a:      -----------
(4,9) a:     ---------
(3,7) a:    -------
(4,8) a:     --------

(5,11) a:      -----------
(7,15) a:        ---------------
(8,17) a:         -----------------
(7,15) a:        ---------------
(6,12) a:       ------------

(4,9) a:     ---------
(4,8) a:     --------

--newpage
--heading Example: Poem
But I tried it anyway:

     The reciprocity of our mutual
     destruction, eternity ensured in full
    avarice--consumptive--future cull 
   and the world replaced. dull
    flesh has become vestigial

     this the promise of a god so genial
       he would wipe out all that has been so he can make his will inviolable
        and we must accelerate extraction of the biological
       for when the world is burned and hope gone, we escape: raptural
      the new heaven and earth/a paradise/a lull
    
    salvation ours, stasis makes will null
    holy statues, immovable

--newpage
--heading Lessons learned

* You can do a lot with a little
* Sweet spot between freedom and constraint
* Constraining too much is interesting exercise
** but not terrible practical
--boldon
* It felt good 
--boldoff

--newpage
--heading What's left?

So much to do!

* Constraint handling
* Concrete poetry with p5.js
* Concrete poetry with *LaTeX*
* More writing
* A better UI for people who aren't me
* Generation of LaTeX templates

--newpage
--heading Me & my code

* on twitter as @ClarissaAdjoint
* and elsewhere on the small internet as left_adjoint
* github repo: https://github.com/clarissalittler/PoetryForms