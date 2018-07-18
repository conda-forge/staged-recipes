:Comment : mtau deduced from text (said to be 6 times faster than for NaTa)
:Comment : so I used the equations from NaT and multiplied by 6
:Reference : Modeled according to kinetics derived from Magistretti & Alonso 1999
:Comment: corrected rates using q10 = 2.3, target temperature 34, orginal 21

NEURON	{
	SUFFIX Nap_Et2
	USEION na READ ena WRITE ina
	RANGE gNap_Et2bar, gNap_Et2, ina, offm, slom, offma, offmb, sloma, slomb, tauma, taumb, taummax, offh, sloh, offha, offhb, sloha, slohb, tauha, tauhb, tauhmax
}

UNITS	{
	(S) = (siemens)
	(mV) = (millivolt)
	(mA) = (milliamp)
}

PARAMETER	{
	gNap_Et2bar = 0.00001 (S/cm2)
	offm = -52.6 (mV)
	slom = 4.6 (mV)
	offma = -38 (mV)
	offmb = -38 (mV)
	sloma = 6.0 (mV)
	slomb = 6.0 (mV)
	tauma = 5.49451
	taumb = 8.06452
	taummax = 6.0 (ms)
	offh = -48.8 (mV)
	sloh = 10.0 (mV)
	offha = -17 (mV)
	offhb = -64.4 (mV)
	sloha = 4.63 (mV)
	slohb = 2.63 (mV)
	tauha = 347222.2
	tauhb = 144092.2
	tauhmax = 1.0 (ms)
}

ASSIGNED	{
	v	(mV)
	ena	(mV)
	ina	(mA/cm2)
	gNap_Et2	(S/cm2)
	mInf
	mTau
	mAlpha
	mBeta
	hInf
	hTau
	hAlpha
	hBeta
}

STATE	{
	m
	h
}

BREAKPOINT	{
	SOLVE states METHOD cnexp
	gNap_Et2 = gNap_Et2bar*m*m*m*h
	ina = gNap_Et2*(v-ena)
}

DERIVATIVE states	{
	rates()
	m' = (mInf-m)/mTau
	h' = (hInf-h)/hTau
}

INITIAL{
	rates()
	m = mInf
	h = hInf
}

PROCEDURE rates(){
  LOCAL qt
  qt = 2.3^((34-21)/10)

	UNITSOFF
	mInf = 1.0/(1+exp((offm-v)/slom))
        if(v == offma){
	    v = v+0.0001
        }
        if(v == offmb){
	    v = v+0.0001
        }
	mAlpha = -(offma-v)/(1-(exp((offma-v)/sloma)))/tauma
	mBeta  = (offmb-v)/(1-(exp(-(offmb-v)/slomb)))/taumb
	mTau = taummax*(1/(mAlpha + mBeta))/qt

	if(v == offha){
	    v = v + 0.0001
	}
        if(v == offhb){
            v = v+0.0001
        }

	hInf = 1.0/(1+exp(-(offh-v)/sloh))
        hAlpha = (offha-v) / (1 - exp(-(offha-v)/sloha))/tauha
        hBeta = -(offhb-v) / (1 - exp((offhb-v)/slohb))/tauhb
	hTau = tauhmax*(1/(hAlpha + hBeta))/qt
	UNITSON
}
