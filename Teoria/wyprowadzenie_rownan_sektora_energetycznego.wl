(* English textbook derivation of the three local SWW specifications.
   Get[this file] rebuilds the NB and PDF. No backups; model files are read only. *)
Begin["SWWComparativeDerivation`"];
ClearAll["SWWComparativeDerivation`*"];
base=DirectoryName[$InputFileName];project=DirectoryName[base];
stems={"SWW_klasyczny","SWW_energia_zywnosc","SWW_energia_w_produkcji"};
paths=FileNameJoin[{project,#,ToLowerCase[#]<>".mod"}]&/@stems;
raw=Import[#,"Text"]&/@paths;
rows=StringCases[#,RegularExpression["(?s)\\[name\\s*=\\s*'([^']*)'\\]\\s*([^;]*);"]->{"$1","$2"}]&/@raw;
canon[s_]:=StringReplace[s,WhitespaceCharacter->""];
byNumber=Association[Map[(First[StringSplit[#[[1]]," "]]->canon[#[[2]]])&,#]]&/@rows;
changed=Select[Keys[byNumber[[3]]],Lookup[byNumber[[2]],#,"missing"] =!= Lookup[byNumber[[3]],#]&];
bl=1-al-nu;fn=aa kk^al nn^bl ee^nu;
ass=aa>0&&kk>0&&nn>0&&ee>0&&al>0&&nu>0&&al+nu<1&&rr>0&&ww>0&&pp>0&&target>0;
unit=(rr/al)^al (ww/bl)^bl (pp/nu)^nu/aa;
dem={al unit target/rr,bl unit target/ww,nu unit target/pp};
pc2=pd^(1-we)pe^we;agg2=(cn/(1-we))^(1-we)(ce/we)^we;
pc3=pd^(1-we-wf)pe^we pf^wf;agg3=(cn/(1-we-wf))^(1-we-wf)(ce/we)^we(cf/wf)^wf;
asm2=pd>0&&pe>0&&cons>0&&0<we<1;asm3=asm2&&pf>0&&wf>0&&we+wf<1;
checks=<|
"Numbered core equation counts"->((Length/@rows)=={42,64,60}),
"Food changes only CPI and sticky/flexible export financing among shared equations"->(Sort[changed]=={"01","11","35"}),
"Four added food equations"->(Sort[Complement[Keys[byNumber[[2]]],Keys[byNumber[[3]]]]]=={"61","62","63","64"}),
"Production shares add to one"->FullSimplify[al+bl+nu==1],
"Euler identity"->FullSimplify[kk D[fn,kk]+nn D[fn,nn]+ee D[fn,ee]==fn,ass],
"Cost-minimising inputs reproduce output"->FullSimplify[(fn/.Thread[{kk,nn,ee}->dem])==target,ass],
"Minimal variable cost"->FullSimplify[{rr,ww,pp}.dem==unit target,ass],
"Two-good expenditure duality"->FullSimplify[(agg2/.{cn->(1-we)pc2 cons/pd,ce->we pc2 cons/pe})==cons,asm2],
"Three-good expenditure duality"->FullSimplify[(agg3/.{cn->(1-we-wf)pc3 cons/pd,ce->we pc3 cons/pe,cf->wf pc3 cons/pf})==cons,asm3],
"Relative CPI identity"->FullSimplify[Log[pc3/pd]==we Log[pe/pd]+wf Log[pf/pd],asm3],
"Weighted factor FOCs imply marginal cost"->FullSimplify[((bl(mh+xh-nh)+al(mh+xh-kh)+nu(mh+xh-eh))/.xh->ah+al kh+bl nh+nu eh)==mh+ah],
"Resource shares add up"->FullSimplify[((1-we-wf)cc+ii+gg+nu+we cc+wf cc)/.cc->1-ii-gg-nu]==1,
"Equivalent classic capital-output formulas"->FullSimplify[psi ratio^(al-1)==al/rr/.ratio->(rr psi/al)^(1/(1-al)),rr>0&&psi>0&&0<al<1],
"Habit coefficient algebra"->FullSimplify[(c0-(cnxt+h cprev-(1-h)rate)/(1+h))(1+h)-((1+h)c0-cnxt-h cprev+(1-h)rate)==0,0<=h<1],
"Wage-deflator identity"->(Expand[(w0-pc0)-(wprev-pcprev)+(pi0+pc0-pcprev)]===w0-wprev+pi0),
"Zero-food log-price limit"->(((we pex+wf pfx)/.wf->0)==we pex)
|>;
If[!And@@(TrueQ/@Values[checks]),Print["Failed checks: ",Select[checks,!TrueQ[#]&]];Exit[2]];
cells={};num=0;
add[c_]:=(AppendTo[cells,c];);
text[s_]:=add[Cell[s,"Text"]];
section[s_]:=add[Cell[s,"Section"]];sub[s_]:=add[Cell[s,"Subsection"]];
symbolPretty[expr_]:=expr/.{
 alpha->\[Alpha],alphaN->Subscript[\[Alpha],N],nu->\[Nu],beta->\[Beta],delta->\[Delta],tau->\[Tau],lambda->\[Lambda],xi->\[Xi],Phi->\[CapitalPhi],
 psiP->Subscript[\[Psi],P],psiU->Subscript[\[Psi],U],phiI->Subscript[\[Phi],I],hstar->Superscript[h,"*"],
 omegaE->Subscript[\[Omega],E],omegaF->Subscript[\[Omega],F],omegaU->Subscript[\[Omega],U],
 gammaP->Subscript[\[Gamma],P],gammaW->Subscript[\[Gamma],W],thetaP->Subscript[\[Theta],P],thetaW->Subscript[\[Theta],W],thetaE->Subscript[\[Theta],e],
 kappaP->Subscript[\[Kappa],P],kappaW->Subscript[\[Kappa],W],kappaE->Subscript[\[Kappa],e],epsP->Subscript[\[CurlyEpsilon],P],epsW->Subscript[\[CurlyEpsilon],W],
 rhoE->Subscript[\[Rho],E],rhoF->Subscript[\[Rho],F],rhoR->Subscript[\[Rho],R],etaE->Subscript[\[Eta],E],etaF->Subscript[\[Eta],F],
 phiPi->Subscript[\[Phi],\[Pi]],phiY->Subscript[\[Phi],y],phiDY->Subscript[\[Phi],\[CapitalDelta] y],
 epsilonb->Subscript[\[Epsilon],b],epsilonq->Subscript[\[Epsilon],q],epsilonp->Subscript[\[Epsilon],p],epsilonw->Subscript[\[Epsilon],w],epsilonr->Subscript[\[Epsilon],r],epsilons->Subscript[\[Epsilon],s],
 piC->Superscript[\[Pi],C],piE->Superscript[\[Pi],E],piF->Superscript[\[Pi],F],piTarget->Superscript[\[Pi],target],pi->\[Pi],
 pE->Subscript[p,E],pF->Subscript[p,F],pc->Subscript[p,C],PD->Subscript[P,D],PE->Subscript[P,E],PF->Subscript[P,F],PC->Subscript[P,C],
 CN->Subscript[C,N],CE->Subscript[C,E],CF->Subscript[C,F],En->Subscript[E,n],Cagg->Superscript[C,agg],
 sN->Subscript[s,N],sE->Subscript[s,E],sF->Subscript[s,F],sC->Subscript[s,C],sI->Subscript[s,I],sV->Subscript[s,V],sG->Subscript[s,G],sX->Subscript[s,X],
 sEn->Subscript[s,En],sCe->Subscript[s,Ce],sCF->Subscript[s,CF],sME->Subscript[s,ME],sGDP->Subscript[s,GDP],sNout->Subscript[s,CN],
 thetaEn->Subscript[\[Theta],En],thetaCe->Subscript[\[Theta],Ce],thetaXE->Subscript[\[Theta],XE],thetaXF->Subscript[\[Theta],XF],
 Xbar->OverBar[X],Ybar->OverBar[Y],Zbar->OverBar[Z],RKbar->OverBar[Subscript[R,K]],wbar->OverBar[w],mbar->OverBar[m],
 PEbar->OverBar[Subscript[P,E]],PDbar->OverBar[Subscript[P,D]],PCbar->OverBar[Subscript[P,C]],Enbar->OverBar[Subscript[E,n]],
 rK->Subscript[r,K],wD->Subscript[w,D],pElevel->Superscript[Subscript[p,E],level],wc->Subscript[w,C],
 q1->Subscript[q,1],i1->Subscript[i,1],i2->Subscript[i,2],k1->Subscript[k,1],k2->Subscript[k,2],c1->Subscript[c,1],c2->Subscript[c,2],vz->Subscript[v,z]
};
(* Printed mathematics uses time subscripts, neutral letter labels, and an
   explicit conditional-expectation box. Computational source is unchanged. *)
labelRules={E->Style["E",FontSlant->Plain],N->Style["N",FontSlant->Italic],C->Style["C",FontSlant->Italic],K->Style["K",FontSlant->Italic],P->Style["P",FontSlant->Italic],F->Style["F",FontSlant->Plain],D->Style["D",FontSlant->Plain]};
timeNames={"zhat","pE","pF","pc","PE","PF","PD","PC","C","Cagg","S","lambda","lambdaHat","uh","c","cnext","piC","epsilonb","r","kbar","i","q","epsilonq","k","v","rk","X","Y","y","A","K","N","a","n","gcontrib","CN","CE","CF","Pj","Cj","xi","cfood","cn","ce","piE","piF","pi","wc","w","u","z","epsilons","e","epsilonw","un","l","piTarget","gap","epsilonr","epsilonp","En","rK","wD","m","pElevel","mc","en","EX","etot","exports","Inv","UtilCost","Gov","GDPreal","gdp","wf","rkf","enf","yf","cnf","cf","cef","cfoodf","zf","nf","qf","rf","gdpf","etaE","etaF","kbarf","invf","kf","vf","ef"};
expectationPrint/:MakeBoxes[expectationPrint[x_,d_],TraditionalForm]:=RowBox[{SubscriptBox["\[DoubleStruckCapitalE]",ToBoxes[d,TraditionalForm]],"[",ToBoxes[x,TraditionalForm],"]"}];
pretty[expr_]:=Module[{v=expr},
 v=v/.HoldPattern[Expectation[x_,info[dt_]]]:>expectationPrint[x,dt];
 v=v/.(HoldPattern[f_Symbol[d_]]/;MemberQ[timeNames,SymbolName[Unevaluated[f]]]):>Subscript[symbolPretty[Unevaluated[f]]/.labelRules,d];
 v=symbolPretty[v];
 v=v/.{lambdaHat->Overscript[\[Lambda],"^"],zhat->Overscript[z,"^"],GDPreal->Superscript[Style["GDP",FontSlant->Plain],"real"],gcontrib->Subscript[g,"contribution"],piTarget->Superscript[\[Pi],"target"],UtilCost->Style["UC",FontSlant->Plain],Gov->G,Inv->Style["I",FontSlant->Italic],EX->Style["EX",FontSlant->Plain]};
 v/.labelRules
];
(* Direct box renderer: expressions remain held; N[t], C[t] and E labels
   can never be evaluated as system functions or constants. *)
atomBox[name_String]:=Module[{v},
 v=Switch[name,
 "zhat",Overscript[Style["z",Italic],"^"],"lambdaHat",Overscript[\[Lambda],"^"],
 "kbar",OverBar[Style["k",Italic]],"Kbar",OverBar[Style["K",Italic]],
 "rk",Subscript[Style["r",Italic],"K"],"rkf",Superscript[Subscript[Style["r",Italic],"K"],"f"],
 "gcontrib",Subscript[Style["g",Italic],"contribution"],"GDPreal",Superscript[Style["GDP",Plain],"real"],
 "wf",Superscript[w,"f"],"cf",Superscript[c,"f"],"yf",Superscript[y,"f"],"nf",Superscript[n,"f"],"qf",Superscript[q,"f"],"rf",Superscript[r,"f"],"cnf",Superscript[Subscript[c,"N"],"f"],"cef",Superscript[Subscript[c,"E"],"f"],"enf",Superscript[Subscript[e,"n"],"f"],"gdpf",Superscript[Style["gdp",Italic],"f"],"cfoodf",Superscript[Subscript[c,"F"],"f"],"zf",Superscript[z,"f"],"Inv",Style["I",Italic],"UtilCost",Style["UC",Plain],"Gov",Style["G",Italic],
 "EX",Style["EX",Plain],"exports",Style["ex",Italic],"cfood",Subscript[Style["c",Italic],"F"],
 "cn",Subscript[Style["c",Italic],"N"],"ce",Subscript[Style["c",Italic],"E"],"en",Subscript[Style["e",Italic],"n"],
 "KY",FractionBox["K","Y"],"IY",FractionBox["I","Y"],"NK",FractionBox["N","K"],
 _,symbolPretty[ToExpression[name,InputForm]]/.labelRules];
 If[MatchQ[v,_FractionBox],v,(ToBoxes[v,TraditionalForm]/.str_String:>StringReplace[str,"\""->""]) ]
];
heldParts[h_HoldComplete]:=Module[{len},len=h/.HoldComplete[_[a___]]:>Length[HoldComplete[a]];Table[Extract[h,{1,j},HoldComplete],{j,len}]];
heldName[HoldComplete[x_Symbol]]:=SymbolName[Unevaluated[x]];
isPlus[h_]:=MatchQ[h,HoldComplete[Plus[___]]];
isNeg[h_]:=MatchQ[h,HoldComplete[Times[-1,___]]|HoldComplete[_Integer?Negative]|HoldComplete[_Rational?Negative]];
positiveHeld[h_]:=h/.{HoldComplete[Times[-1,a___]]:>HoldComplete[Times[a]],HoldComplete[n_Integer?Negative]:>With[{p=-n},HoldComplete[p]],HoldComplete[n_Rational?Negative]:>With[{p=-n},HoldComplete[p]]};
paren[b_]:=RowBox[{"(",b,")"}];
productBoxes[parts_]:=Module[{bs},bs=(If[isPlus[#],paren[mathBox[#]],mathBox[#]]&/@parts);If[bs=={},"1",RowBox[Riffle[bs,"\[ThinSpace]"]]]];
mathBox[HoldComplete[x_Symbol]]:=atomBox[SymbolName[Unevaluated[x]]];
mathBox[HoldComplete[x_Integer]]:=ToString[x];
mathBox[HoldComplete[x_Rational]]:=FractionBox[ToString[Numerator[x]],ToString[Denominator[x]]];
mathBox[HoldComplete[x_Real]]:=ToString[x,InputForm];
mathBox[h:HoldComplete[Expectation[x_,info[d_]]]]:=RowBox[{SubscriptBox["\[DoubleStruckCapitalE]",mathBox[HoldComplete[d]]],"[",mathBox[HoldComplete[x]],"]"}];
mathBox[h:HoldComplete[Equal[___]]]:=RowBox[Riffle[mathBox/@heldParts[h],"="]];
mathBox[h:HoldComplete[Plus[___]]]:=Module[{ps=heldParts[h],bs},bs=MapIndexed[If[isNeg[#1],RowBox[{"-",mathBox[positiveHeld[#1]]}],If[First[#2]==1,mathBox[#1],RowBox[{"+",mathBox[#1]}]]]& ,ps];RowBox[bs]];
mathBox[h:HoldComplete[Times[___]]]:=Module[{ps=heldParts[h],top,bot,neg},
 neg=Length[ps]>0&&First[ps]===HoldComplete[-1];If[neg,ps=Rest[ps]];
 bot=Select[ps,MatchQ[#,HoldComplete[Power[_,_Integer?Negative]]]&];top=Select[ps,!MatchQ[#,HoldComplete[Power[_,_Integer?Negative]]]&];
 bot=bot/.HoldComplete[Power[a_,n_Integer]]:>With[{p=-n},If[p==1,HoldComplete[a],HoldComplete[Power[a,p]]]];
 With[{b=If[bot=={},productBoxes[ps],FractionBox[productBoxes[top],productBoxes[bot]]]},If[neg,RowBox[{"-",b}],b]]
];
mathBox[HoldComplete[Power[a_,n_]]]:=SuperscriptBox[If[isPlus[HoldComplete[a]]||MatchQ[HoldComplete[a],HoldComplete[Times[___]]],paren[mathBox[HoldComplete[a]]],mathBox[HoldComplete[a]]],mathBox[HoldComplete[n]]];
mathBox[HoldComplete[Log[a_]]]:=RowBox[{"log",paren[mathBox[HoldComplete[a]]]}];
mathBox[HoldComplete[Disutility[a_]]]:=RowBox[{"\[ScriptV]",paren[mathBox[HoldComplete[a]]]}];
mathBox[h:HoldComplete[f_Symbol[d_]]]/;MemberQ[timeNames,SymbolName[Unevaluated[f]]]:=SubscriptBox[atomBox[SymbolName[Unevaluated[f]]],mathBox[HoldComplete[d]]];
mathBox[h_HoldComplete]:=ToBoxes[h/.HoldComplete->Defer,TraditionalForm];
eq[s_]:=(num++;add[Cell[BoxData[mathBox[ToExpression[s,InputForm,HoldComplete]]],"DisplayFormula",CellFrameLabels->{{None,"("<>ToString[num]<>")"},{None,None}}]];);
code[s_]:=add[Cell[s,"Program",FontSize->9,CellHorizontalScrolling->False]];
add[Cell["From the Classic SWW Model to Energy and Food Extensions","Title"]];
add[Cell["Theoretical derivations for the three local implementations","Subtitle"]];
text["Expanded textbook edition, 20 October 2026. This chapter follows the requested order: SWW_klasyczny, SWW_energia_zywnosc, SWW_energia_w_produkcji. It is written in English, as in the companion annotated notebooks. Levels and optimality conditions are developed before their log-linear counterparts. The PDF is the reading edition; this Wolfram script and the notebook are reproducible working sources. No backups are created."];
text["Important scope distinction. This order is not a demonstrated development chronology. The food README describes an extension of an energy-model diagnostic variant. Both sectoral folders already contain energy in production AND household consumption. The last step in the requested order therefore removes imported food; it does not introduce energy for the first time. We compare the actual main .mod files and EA20 calibration, measurement and shock modules, rather than infer mechanisms from folder names."];
text["A linear model does not uniquely identify its nonlinear foundations. The household-habit and cost-minimisation problems below are explicit compatible reconstructions. The inherited SWW investment, wage, employment and utilisation blocks are documented with their implemented coefficients; a unique nonlinear microfoundation is not asserted where it is not specified in the local files. Algebraic checks here do not replace solving or estimating the stochastic model. No new Dynare simulation or determinacy test is claimed."];
section["1. Model map, notation and timing"];
text["Classic: one domestic consumption good, capital and labour in production, domestic inflation relevant for consumption and policy, and y used as GDP. It has 42 numbered core equations and eight innovations. Energy-food: a three-good consumption basket, energy as an imported intermediate input, imported final food, distinct CPI and domestic inflation, explicit GDP, 64 core equations and ten innovations. Energy-only retains both energy channels but removes food, leaving 60 core equations and nine innovations. Measurement equations are additional to these counts."];

sub["1.1 What an equilibrium model assumes"];
text["A DSGE model describes households and firms making decisions under constraints, and prices making those decisions mutually compatible. Dynamic means that choices today affect tomorrow: saving changes future resources, investment changes future capital, and a wage or price set today may remain effective for several periods. Stochastic means that agents face innovations they cannot perfectly forecast. General equilibrium means that consumption, production, wages, interest rates and policy are solved together, rather than changed one at a time while everything else is held fixed."];
text["These words matter for reading a derivation. A firm's condition for a given output target is not yet an equilibrium output equation. A household's demand for energy at a given expenditure level is not yet the full consumption response to an energy shock. We first derive such conditional decisions, then combine them with resource constraints, price adjustment, policy and expectations. An impulse response follows from that complete system."];
sub["1.2 Steady states, trends and local approximations"];
text["The steady state is the reference allocation around which deviations are measured. It need not imply that observed GDP is literally constant: after removing a balanced-growth trend, ratios and suitably scaled quantities can be constant while their original levels grow. Detrending is the operation that separates this predictable growth component from cyclical movements. Here tau, the gross trend-growth factor, enters capital accumulation and habit-adjusted consumption because yesterday's and today's levels are measured on different trend scales."];
text["Log-linearisation approximates the equilibrium near that reference allocation. For a positive variable, its log change is approximately its percentage change for small movements. Thus a value of 2 in a 100-log deviation means a level about 2.02% above the reference, not two extra physical units. A linear equation is useful for tracing propagation and expectations, but it need not describe a large crisis or an allocation near a feasibility boundary. This is why positivity and steady-state restrictions are part of the mathematics, rather than optional technical footnotes."];

eq["zhat[t] == 100 Log[Z[t]/Zbar]"];
text["Upper-case symbols denote positive levels. Lower-case quantities and relative prices denote 100 times log deviations from steady state, unless explicitly identified as rate, unemployment or shock variables with a different convention. Inflation and interest rates are quarterly percentage-point deviations. In the economic interpretation, forward-looking endogenous quantities are conditional expectations E_t; the code's (+1) is a lead, not a known future outcome. A lag is t−1."];
text["Do not apply the 100-log convention blindly to all shocks: epsilonp and epsilonw are explicitly multiplied by 100 in their equations. epsilong is already the additive government contribution in the resource equation. Unemployment u and un use the source's unemployment-rate convention. ryear=4r approximately annualises the quarterly rate."];
eq["pE[t] == 100 Log[(PE[t]/PD[t])/(PEbar/PDbar)]"];
eq["pc[t] == 100 Log[(PC[t]/PD[t])/(PCbar/PDbar)]"];
text["pF is the analogous relative food price. pi is domestic-goods inflation, piC consumption inflation, and piE/piF imported-good inflation. w is the nominal wage deflated by PD; wc uses PC. rk is the rental return on capital services, distinct from the nominal bond rate r. k denotes services; kbar installed capital. X denotes technological output before fixed costs, Y=X−Φ output after the fixed cost, and GDP domestic value added after subtracting imported intermediate energy."];
section["2. The classic benchmark and common dynamic core"];
sub["2.1 Derive the consumption equation"];
text["A compatible reconstruction of the implemented coefficients uses log utility of an external-habit surplus S_t=C_t−h C_(t−1)^agg. The household treats the aggregate lagged habit as given; internal habit would add future-utility effects to the derivative. Detrending at gross growth τ gives an effective habit coefficient h*=h/τ, with 0≤h*<1. The surplus must remain positive."];

sub["Habit formation: consumption relative to a reference standard"];
text["Habit formation means that the satisfaction from current consumption depends on a reference level inherited from the past. Think of a household accustomed to a particular standard of living. A consumption level that previously seemed generous may feel restrictive after a period of higher expenditure. In the specification used to reconstruct this block, utility depends on surplus consumption S: actual consumption minus a fraction h of a lagged reference. Habit is therefore a change in preferences over consumption paths, rather than a literal extra purchase in the budget."];
text["The parameter h measures the strength of the reference standard. If h=0, utility depends on current consumption alone. If h is positive, keeping consumption unchanged after a rise in the reference leaves a smaller surplus and therefore a higher marginal utility of resources. For a numerical illustration, with current consumption 100, lagged reference 90 and h=0.6, the surplus is 46. At the same current consumption but a reference of 100, the surplus is 40. Under log-surplus utility, marginal utility rises from 1/46 to 1/40. These numbers illustrate preferences; they do not imply that expenditure is 46 or that 54 units disappear from production."];
text["External and internal habit are different assumptions. With external habit, a small household compares itself with past aggregate consumption and treats that benchmark as outside its individual control. In a symmetric equilibrium, individual and aggregate consumption may have the same realised value, but they must not be treated as the same choice variable when differentiating. With internal habit, today's own consumption also changes tomorrow's own benchmark. Its lifetime derivative therefore includes an extra future-utility term. Substituting internal habit into a derivation based on external habit would generally change the Euler equation."];
text["For the compatible external-habit reconstruction, the period utility contribution is log(S) less a labour-disutility term. Log utility is defined only for S>0. This says that consumption must exceed the habit-adjusted reference, a stronger requirement than merely C>0. We do not introduce a new freely estimated CRRA coefficient here: the unit curvature of log-surplus utility is what reproduces the simple c1 and c2 coefficients in the local files."];
eq["uh[t] == Log[S[t]]-Disutility[N[t]]"];

eq["S[t] == C[t]-h Cagg[t-1]"];
eq["lambda[t] == 1/S[t]"];
text["The nominal bond FOC is λ_t=β E_t[λ_(t+1)R_t/ΠC_(t+1)], augmented by the model's risk-premium wedge. Marginal utility linearises as λ-hat_t=−(c_t−h*c_(t−1))/(1−h*). Insert this relation into the bond Euler equation, multiply by 1−h*, collect the two terms containing c_t, and divide by 1+h*. The resulting consumption equation is:"];

sub["From marginal utility to an Euler equation"];
text["An Euler equation compares two feasible uses of one additional unit of resources: consume it today, or save it and consume its payoff tomorrow. The multiplier lambda measures the utility value of an extra unit of current purchasing power. The discount factor beta weights future utility. The gross nominal payoff must be divided by future consumption-price inflation because tomorrow's money buys goods at tomorrow's prices. Under uncertainty, expected discounted marginal utility times the real payoff is the relevant object; the expectation is conditional on information available today."];
text["The following two first-order relations make the intermediate algebra visible. The hat on lambda denotes its 100-log deviation. The interest-rate and premium terms follow the source's linear units. The first relation comes from differentiating log marginal utility around the positive trend-adjusted surplus; the second is the log-linear nominal bond condition. Together they explain why lagged consumption enters the final demand equation."];
eq["lambdaHat[t] == -(c[t]-hstar c[t-1])/(1-hstar)"];
eq["lambdaHat[t] == Expectation[lambdaHat[t+1],info[t]]+r[t]-Expectation[piC[t+1],info[t]]-epsilonb[t]"];
eq["(1+hstar)c[t] == Expectation[c[t+1],info[t]]+hstar c[t-1]-(1-hstar)(r[t]-Expectation[piC[t+1],info[t]]-epsilonb[t])"];
text["Dividing the last line by 1+h* gives the implemented equation below. Habit adds a backward-looking element through past consumption while preserving a forward-looking element through expected consumption. It also changes the direct coefficient on the expected real rate. With h*=0, c1=c2=1 and there is no lagged-consumption term. As h* approaches one from below, c1 approaches one half, the lag weight approaches one half, and c2 approaches zero. This is a statement about coefficients in the conditional linear equation, not a guarantee that every general-equilibrium consumption response becomes smaller."];
text["Habit persistence must also be distinguished from shock persistence. Habit makes past consumption relevant even if an innovation itself is short lived. A persistent shock keeps a disturbance alive through its own stochastic law. A model can have both mechanisms; observing a slow consumption response alone does not identify which one generated it. The parameter restriction h*=h/tau<1 also protects the positive steady surplus after accounting for trend growth."];

eq["c[t] == c1 Expectation[c[t+1],info[t]]+(1-c1)c[t-1]-c2(r[t]-Expectation[piC[t+1],info[t]]-epsilonb[t])"];
eq["c1 == 1/(1+hstar)"];
eq["c2 == (1-hstar)/(1+hstar)"];
text["In the implementation hstar=ch/ctau. Classic PC=PD implies piC=pi and recovers classic equation 01. Both sectoral versions use piC in equation 07. A CRRA curvature other than one would change the simple real-rate loading; the elementary CRRA-labour notebook is not a literal complete derivation of these habit coefficients. The precise structural origin of the financial/preference wedge epsilonb is not identified by its reduced-form loading alone."];
sub["2.2 Capital, investment and utilisation"];
text["The inherited investment block corresponds to capital accumulation with investment efficiency and adjustment costs. The local linear files do not uniquely specify the nonlinear adjustment function. Its detrended first-order laws are therefore stated with the actual coefficients, rather than attributed to a unique unobserved level function."];

sub["What capital adjustment costs and Tobin's q mean"];
text["Investment is a flow of newly created capital; installed capital is a stock accumulated over time. Depreciation delta is the fraction of the existing stock lost in a period. If delta=0.025, 2.5% depreciates per quarter under the stated quarterly timing. Capital services are the productive flow delivered by that stock, which can also vary with how intensively machinery is used. These distinctions explain why the model needs i, kbar, k and v rather than one undifferentiated capital variable."];
text["Adjustment costs express the idea that rapidly changing the investment programme is costly. Hiring installation teams, reorganising production or absorbing new equipment cannot always be done instantly. The cost is associated with changing investment, so the optimality condition involves past and expected future investment as well as q. This provides economic inertia without assuming that firms simply ignore profitable opportunities. The investment-efficiency process is a separate disturbance to how effective investment is; its precise nonlinear placement cannot be recovered uniquely from the linear equations alone."];
text["Tobin's q is the shadow value of an additional unit of installed capital relative to the price of acquiring investment goods. Around the chosen reference, a positive q deviation makes investment more attractive. The investment equation translates that incentive into an adjustment path. A capital-value equation then links today's q to tomorrow's rental payoff and resale value, discounted by the relevant return. This makes q a forward-looking valuation variable, not a new physical quantity produced by firms."];

eq["kbar[t] == k1 kbar[t-1]+(1-k1)i[t]+k2 epsilonq[t]"];
eq["i[t] == i1 i[t-1]+(1-i1)Expectation[i[t+1],info[t]]+i2 q[t]+epsilonq[t]"];
eq["k1 == (1-delta)/tau"];
eq["i1 == 1/(1+beta)"];
eq["i2 == i1/(tau^2 phiI)"];
eq["k2 == (tau+delta-1)(1+beta)tau phiI"];
text["cphi=φI measures investment adjustment curvature. The lag in k=v+kbar(−1) means installed capital is predetermined when current services are used. Utilisation v adjusts the services flow, and a higher rental return raises its desired intensity. cpsi=ψU is the utilisation parameter."];
eq["k[t] == v[t]+kbar[t-1]"];
eq["v[t] == ((1-psiU)/psiU)rk[t]"];
eq["q[t] == -(r[t]-Expectation[pi[t+1],info[t]]-epsilonb[t])+q1 Expectation[rk[t+1],info[t]]+(1-q1)Expectation[q[t+1],info[t]]"];
eq["q1 == RKbar/(RKbar+1-delta)"];
text["The capital-value condition discounts domestic-good rental and resale payoffs. Since q is measured in domestic investment goods, its real-rate deflator remains domestic inflation pi, even when consumption uses CPI. The weights q1 and 1−q1 are the steady rental and undepreciated resale shares in the total capital payoff."];
sub["2.3 Production and fixed costs in the classic model"];

sub["Constant returns, marginal productivity and fixed costs"];
text["A production exponent is an elasticity: it describes the percentage change in output from a small percentage change in an input, holding other inputs fixed. The sum of the exponents determines returns to scale. When it is one, doubling all variable inputs doubles technological output X. This does not contradict a decreasing marginal product of capital: that statement increases capital alone while holding labour and, in the sectoral version, energy fixed."];
text["The fixed cost Phi is expressed in units of the domestic good. It reduces saleable output from X to Y, but does not change how much an additional small input contributes to X. It creates a distinction between marginal cost and average cost: resources needed to cover a fixed requirement are spread over more units as production expands. In the local model, the steady fixed-cost and markup normalisations are tied through cpsip. That equality is a maintained calibration convention, not a universal property of any economy with a fixed cost."];

eq["X[t] == A[t] K[t]^alpha N[t]^(1-alpha)"];
eq["Y[t] == X[t]-Phi"];
eq["psiP == Xbar/Ybar"];
eq["y[t] == psiP(a[t]+alpha k[t]+(1-alpha)n[t])"];
text["For constant Φ and Ȳ>0, dY=dX and dY/Ȳ=(X̄/Ȳ)dX/X̄. This explains cpsip=ψP in the linear production function. Log additivity for X is exact; mapping X to Y is first-order. Without imported intermediate inputs, Y also serves as GDP in the classic output gap and measurement equation."];
eq["y[t] == sC c[t]+sI i[t]+sV v[t]+gcontrib[t]"];
text["This linear resource equation follows from Y=C+I+UtilisationCost+G. The coefficients are steady expenditure shares or, for utilisation, the derivative of its cost divided by Ȳ. epsilong=gcontrib is already a weighted additive contribution, not an unweighted government log deviation. A zero steady utilisation cost need not imply a zero marginal utilisation cost."];
section["3. Derive commodity demand and the consumption price index"];
sub["3.1 Energy-food consumption basket"];
text["Let sN=1−ωE−ωF, sE=ωE and sF=ωF, all positive. CN is domestic non-energy non-food consumption, CE household energy and CF imported food. Both sectoral models implement a Cobb–Douglas basket with unit elasticity of substitution, not a general CES basket with a freely varying substitution parameter."];

sub["Why introduce a consumption basket?"];
text["A household consumes different goods but needs a single index to describe the flow of consumption services entering utility. The basket is such an index. It is not obtained by simply adding tonnes of energy, food quantities and domestic goods. Its aggregation rule specifies how combinations of goods substitute for one another. The associated consumption price index tells us the minimum expenditure needed to purchase one unit of that composite at current prices."];
text["The Cobb-Douglas rule imposes two strong restrictions. First, all positively weighted components are essential for a positive composite, so an interior derivation uses positive quantities. Second, optimal expenditure shares are constant. With positive prices, the household spends the fraction omegaE on energy and omegaF on imported food, although the purchased quantities change with prices. Constant shares do not mean constant quantities. When the energy price rises, energy demand falls so that its expenditure share remains fixed at the optimum."];
text["A unit substitution elasticity means that, conditionally on the basket's required service level, a one-percent change in a relative price produces an approximately one-percent change in the corresponding relative quantity. This is a tractable benchmark, not an empirical claim that households can easily replace every energy service or food product. Allowing a different elasticity requires a general CES aggregator and changes the demand equations and price index. The local implementation deliberately uses the simpler unit-elastic case."];

eq["C[t] == (CN[t]/sN)^sN (CE[t]/sE)^sE (CF[t]/sF)^sF"];
eq["sN+sE+sF == 1"];
text["Minimise PD·CN+PE·CE+PF·CF for a required composite C. The composite derivative is s_j C/C_j, so the cost FOC is P_j=ξ s_j C/C_j. Multiply each FOC by C_j and add: expenditure equals ξC. Substituting the demands back into the aggregator yields ξ=PC, the unit-expenditure function."];
eq["Pj[t] == xi[t] sj C[t]/Cj[t]"];
eq["PC[t] == PD[t]^sN PE[t]^sE PF[t]^sF"];
eq["CN[t] == sN(PC[t]/PD[t])C[t]"];
eq["CE[t] == sE(PC[t]/PE[t])C[t]"];
eq["CF[t] == sF(PC[t]/PF[t])C[t]"];
text["Normalising quantities by their weights removes constant share factors from the dual price index. Such constants disappear in log deviations but matter for level derivations. The level symbol CF for food must not be confused with Dynare cf, which means total flexible-price consumption; food is cfood in the code."];
sub["3.2 Log deviations and the two-good reduction"];
eq["pc[t] == omegaE pE[t]+omegaF pF[t]"];
eq["cn[t] == c[t]+pc[t]"];
eq["ce[t] == c[t]+pc[t]-pE[t]"];
eq["cfood[t] == c[t]+pc[t]-pF[t]"];
text["Subtract the steady-state log identities to remove constant shares. Conditional on fixed total C and other relative prices, a one-log-percent rise in pF raises pc by ωF, reduces food demand by 1−ωF, and raises domestic demand by ωF. Full equilibrium consumption and policy are not held fixed in an impulse response."];
eq["C[t] == (CN[t]/(1-omegaE))^(1-omegaE)(CE[t]/omegaE)^omegaE"];
text["Removing food gives this two-good basket and pc=ωE pE, with the same cn and ce log equations. At ωF=0 take the continuous reduced-model limit; do not insert zero directly into CF/ωF. Zero-share quantities cannot be log-linearised around a zero level."];section["4. Deflators, wages, monetary policy and domestic prices"];

text["A deflator converts a nominal amount into purchasing power measured in a particular good or basket. Suppose nominal earnings stay unchanged while household energy becomes more expensive. The wage measured in domestic goods can stay constant if the domestic-good price has not changed, yet the same earnings purchase less of the consumption basket. Hence w and wc answer different questions. The distinction is central when imported prices move independently of domestic prices."];
text["The assumption of a domestic numeraire is a choice of units: dividing by PD does not assume that the domestic price is constant in nominal terms. Relative prices PE/PD and PC/PD can change, and domestic inflation pi remains an endogenous variable. A constant normalised steady relative price also does not prevent dynamic relative-price shocks."];

sub["4.1 Inflation accounting"];
text["The identity PC=PD·(PC/PD) implies that consumption inflation is domestic inflation plus the change in the relative consumption price. The same argument applies to each imported good. The term added to inflation is a price CHANGE, not the relative price level itself."];
eq["piC[t] == pi[t]+pc[t]-pc[t-1]"];
eq["piE[t] == pi[t]+pE[t]-pE[t-1]"];
eq["piF[t] == pi[t]+pF[t]-pF[t-1]"];
text["The sectoral consumption Euler equation uses expected piC, whereas capital valuation still uses expected pi. Replacing both deflators by CPI would change the units of the domestic investment payoff incorrectly."];
sub["4.2 Purchasing-power wages and the labour-market block"];
eq["wc[t] == w[t]-pc[t]"];
eq["omegaU u[t] == wc[t]-(z[t]+epsilons[t]+omegaU e[t])"];
eq["z[t] == (1-vz)z[t-1]+vz/(1-hstar)(c[t]-hstar c[t-1])"];
text["The household's reservation-wage term depends on smoothed habit-adjusted consumption z, labour-supply wedge epsilons and employment e. comega=ωU and cv=vz. Classic uses w, since its PC=PD; sectoral versions use wc. A commodity-price increase can therefore lower consumption purchasing power at an unchanged domestic-real wage. Hours n and employment e remain distinct quantities."];

text["Wage rigidity means that households or wage setters cannot freely reset every wage in every period. A Calvo-style parameter thetaW can be interpreted as the probability that a wage is not reoptimised in a period under a constant-hazard formulation. The indexation coefficient gammaW describes how a wage that is not freshly optimised is mechanically updated with past inflation. Indexation and reoptimisation are therefore distinct: an indexed wage may change without the setter choosing a new optimal wage."];
text["The unemployment term summarises a gap between wage compensation and the reservation-wage side of the labour market. Higher unemployment and a wage-markup disturbance affect bargaining or wage-setting pressure through the implemented reduced block. A natural unemployment variable here is a model counterfactual, not an assertion that all observed unemployment is voluntary or that the benchmark is a welfare optimum."];

eq["wc[t]-wc[t-1]+piC[t] == gammaW piC[t-1]+beta Expectation[wc[t+1]-wc[t]+piC[t+1]-gammaW piC[t],info[t]]-kappaW(omegaU u[t]-100 epsilonw[t])"];
eq["kappaW == ((1-thetaW beta)(1-thetaW))/(thetaW(1+omegaU epsW))"];
text["The left side is nominal wage inflation: Δwc+piC=Δw+pi. This cancellation is a unit-conversion identity. Indexing wages to CPI on the right instead of domestic inflation is a substantive modelling choice in the sectoral files, not an implication of accounting alone. This sticky-wage unemployment block should not be replaced by a frictionless household labour FOC."];
eq["omegaU un[t] == 100 epsilonw[t]"];
eq["l[t] == u[t]+e[t]"];
eq["e[t]-e[t-1] == beta Expectation[e[t+1]-e[t],info[t]]+kappaE(n[t]-e[t])"];
eq["kappaE == ((1-thetaE beta)(1-thetaE))/thetaE"];
text["Employment adjusts gradually towards hours demanded. The relationship l=u+e uses the model's linear normalisation; it is not the exact level unemployment identity without an appropriate conversion. These labour-market mechanisms are inherited across the three versions."];
sub["4.3 Monetary policy and the domestic Phillips curve"];
eq["r[t] == rhoR r[t-1]+(1-rhoR)(phiPi piTarget[t]+phiY gap[t]+phiDY(gap[t]-gap[t-1]))-epsilonr[t]"];
text["Classic sets piTarget=pi; both sectoral versions set piTarget=piC. This is an explicit policy choice. The negative sign on epsilonr is retained: a positive innovation to that process reduces r directly. The domestic price Phillips curve continues to use domestic inflation and domestic-real marginal cost."];

sub["What sticky prices and a Phillips curve assume"];
text["Price rigidity gives a firm a reason to care about future costs when choosing today's price. If a price may remain in place for several periods, the firm must weigh a sequence of expected demand and cost conditions. In a constant-hazard Calvo interpretation, thetaP is the probability of not reoptimising the price in a period. The expected time between reoptimisations is 1/(1−thetaP). For example, thetaP=0.75 corresponds to four quarters. This is an average waiting time, not a rule that every firm changes its price exactly once a year."];
text["The parameter gammaP represents indexation of a non-reoptimised price to past inflation. This introduces lagged inflation, whereas forward-looking price setting introduces expected future inflation. The Phillips curve summarises these forces around the reference equilibrium. Its slope kappaP translates a marginal-cost deviation into inflation pressure. Greater rigidity reduces the frequency of resetting and, under the maintained formula, tends to flatten that relationship."];
text["A markup is the price charged relative to marginal cost. It reflects product-market structure and demand elasticity; it is not the same as a fixed cost or a wedge in household purchasing power. The present calibration connects a steady markup factor with a fixed-cost/output normalisation, but the concepts remain distinct. A domestic Phillips curve governs domestic producer prices. Imported energy and food prices are instead driven by exogenous relative-price laws, so CPI combines domestic price setting with imported-price movements."];

eq["pi[t]-gammaP pi[t-1] == beta Expectation[pi[t+1]-gammaP pi[t],info[t]]+kappaP mc[t]-100 kappaP epsilonp[t]"];
eq["kappaP == ((1-thetaP beta)(1-thetaP))/(thetaP(1+(psiP-1)epsP))"];
text["This is the source expression −pi2(−mc+100epsilonp) rewritten to show its signs. cthetap=θP, cgammap=γP, cepsp=epsP and cpsip=ψP. The price-aggregator curvature correction is inherited. Adding imported food does not add a domestic agricultural technology or a food Phillips curve."];
section["5. Energy in production: derive the firm's cost equations"];
sub["5.1 Production technology and the fixed cost"];

text["Energy in production is an intermediate input: firms buy it to produce something else. Household energy is final consumption: it delivers services directly to households. These uses share an import price here but play different economic roles. A production-energy shock changes the firm's feasible input mix and cost; a household-energy shock channel changes the cost of living. Keeping En and CE separate prevents these two mechanisms from being mixed in resource accounting."];
text["The restriction alpha+nu<1 leaves a strictly positive labour elasticity alphaN. A positive energy exponent means energy is essential in this technology: with zero energy and positive weights, technological output is zero. If nu is set to zero, energy becomes unnecessary and the appropriate object is the reduced two-input technology. Increasing nu while holding alpha fixed reduces the labour exponent; it does not create increasing returns, since the exponent sum remains one."];

eq["X[t] == A[t] K[t]^alpha N[t]^alphaN En[t]^nu"];
eq["alphaN == 1-alpha-nu"];
eq["Y[t] == X[t]-Phi"];
text["Assume α>0, ν>0, α+ν<1, A>0 and positive inputs. The exponents sum to one, giving constant returns to scale. Each input has a positive, decreasing own marginal product: for instance ∂X/∂En=νX/En. Positive cross derivatives express technological complementarity, while cost-driven substitution still has elasticity one."];
eq["y[t] == psiP(a[t]+alpha k[t]+alphaN n[t]+nu en[t])"];
sub["5.2 Cost minimisation and the dual function"];
text["For a given technological output X, minimise RK·K+W·N+PE·En subject to A K^α N^αN En^ν≥X. Divide all prices and the nominal multiplier by PD. The resulting real factor prices are rK, wD and pElevel=PE/PD; m is the real marginal cost in domestic goods. The binding production constraint and the three FOCs give:"];

text["Marginal cost is the minimum additional expenditure needed to produce a small extra unit of output, holding prices and technology fixed. The multiplier on the production target has exactly that interpretation: relaxing the requirement by one unit changes the minimum cost by the multiplier. This is why the same m appears in all three input conditions. At an interior optimum, spending one more unit on any input must buy the same additional output after valuing it at marginal cost."];
text["Strictly positive factor prices rule out obtaining unlimited amounts of an input at no cost. A positive production target and essential positive-weight inputs rule out a zero-input corner. Concavity of the Cobb-Douglas technology makes its production-superlevel feasible set convex, while expenditure is linear. Under these assumptions the cost FOCs characterise a global cost minimum, rather than merely an arbitrary stationary point. These assumptions justify dividing the conditions by positive inputs and using logarithms later."];

eq["rK[t] K[t] == alpha m[t] X[t]"];
eq["wD[t] N[t] == alphaN m[t] X[t]"];
eq["pElevel[t] En[t] == nu m[t] X[t]"];
text["Multiply each marginal product by its input and add. Euler's theorem gives X, so total variable cost equals mX. Substitute K=αmX/rK, N=αN mX/wD and En=νmX/pElevel into the technology; cancel X>0 and use the sum of shares equal to one. Solving for m gives:"];
eq["m[t] == (1/A[t])(rK[t]/alpha)^alpha(wD[t]/alphaN)^alphaN(pElevel[t]/nu)^nu"];
text["Now take logarithms and subtract the steady state. Alternatively, divide the capital FOC by the labour FOC to eliminate m and X; its fixed share constant disappears in log deviations. Finally, take logs of the energy FOC and replace x by y/ψP. This yields equations 14, 16 and 15 of both sectoral files:"];
eq["mc[t] == alphaN w[t]+alpha rk[t]+nu pE[t]-a[t]"];
eq["k[t] == w[t]-rk[t]+n[t]"];
eq["en[t] == mc[t]+y[t]/psiP-pE[t]"];
text["The energy FOC contains X, not Y. Omitting 1/cpsip would mix technological and after-fixed-cost output. Holding wages, rentals and productivity fixed, an energy relative-price increase raises marginal cost by ν times its log change. An equilibrium response also includes adjustments of all other endogenous variables."];
sub["5.3 Scale is not determined by the input FOCs alone"];
text["With a fixed product price and constant returns, profit after cost minimisation is (PD−MCnom)X−PDΦ. Without demand or market clearing, a positive unit margin implies unbounded scale; equality of unit price and variable cost leaves scale undetermined. The cost problem identifies the input mix for a given production target. The sticky-price product-demand and price-setting problems determine its scale. One should distinguish technology, input choice and price choice."];
section["6. Import financing, domestic resources and GDP"];
sub["6.1 The energy-only closure"];
text["Exports of the domestic good finance imports period by period. There is no independently evolving foreign-asset position, exchange-rate equation or foreign demand schedule in this closure. EX is the domestic export volume. Energy used by firms and households faces the same imported price."];

text["A trade closure tells the model how an import bill is financed. In this implementation the bill is paid immediately with exports. A more general open-economy model could let the country borrow abroad, use accumulated foreign assets, change its exchange rate, or face a foreign export-demand schedule. None of those alternatives is automatically present here. The balanced-trade assumption is simple and transparent, but can strongly influence the response of domestic output to an imported-price shock."];
text["For example, a higher imported energy price tends to raise the value of a given import volume. Households and firms adjust their volumes, while the closure requires enough domestic exports to finance the resulting bill. This extra domestic use interacts with declining household purchasing power and higher production costs. It explains why one cannot deduce the sign of GDP by reading the energy cost term alone."];

eq["PD[t] EX[t] == PE[t](En[t]+CE[t])"];
eq["etot[t] == thetaEn en[t]+thetaCe ce[t]"];
eq["exports[t] == pE[t]+etot[t]"];
text["The log approximation to a sum uses steady shares: θEn=En̄/(En̄+CĒ), θCe=1−θEn. The same weights are energy-expenditure shares because both uses share a common price. Adding log changes without these weights would be incorrect. These are equations 10 and 11 in the energy-only file."];
sub["6.2 Add final imported food"];
eq["PD[t] EX[t] == PE[t](En[t]+CE[t])+PF[t] CF[t]"];
eq["exports[t] == thetaXE(pE[t]+etot[t])+thetaXF(pF[t]+cfood[t])"];
text["θXE and θXF are the steady energy and food VALUE shares in total import expenditure. Their sum is one when imports are positive. They differ from θEn and θCe, which divide only energy imports. Food equations 11 and 35 change export financing in the sticky and flexible economies. For zero components use zero weighted contributions and the reduced model; do not take logs of zero levels."];
sub["6.3 The domestic resource constraint"];
eq["Y[t] == CN[t]+Inv[t]+UtilCost[t]+Gov[t]+EX[t]"];
eq["y[t] == sNout cn[t]+sI i[t]+sV v[t]+gcontrib[t]+sX exports[t]"];
text["Domestic consumption, investment, utilisation costs, government and exports exhaust domestic output. Imported CE and CF are not separately added to domestic use: domestic exports finance them. Replacing CN by composite C without adjusting the accounting would misallocate imports."];
sub["6.4 Value added, not nominal import expenditure"];

text["Gross output and value added answer different questions. Gross output counts the value of the goods produced by domestic firms, including production that uses imported intermediate inputs. Value added asks how much production value is generated domestically after those intermediate inputs are removed. If a firm imports energy to produce a final good, counting the whole final good as domestic value added would attribute the imported energy contribution to the domestic economy as well."];
text["Real and nominal value added must also be separated. A current-price import bill can rise because the input becomes more expensive even when its volume does not change. A quantity measure should not report that pure price increase as a drop in physical production. Double deflation therefore values output and intermediate-input volumes at specified base prices before taking the difference. The local first-order GDP equation is an implementation of that convention near the steady state, not a complete chain-linked national-accounts system for arbitrarily large changes."];

eq["GDPreal[t] == Y[t]-(PEbase/PDbase)En[t]"];
eq["gdp[t] == (y[t]-sEn en[t])/sGDP"];
eq["sGDP == 1-sEn"];
text["Equation 28 is a first-order double-deflation quantity measure: intermediate imported energy is subtracted at FIXED base prices. There is no contemporaneous pE term in this real GDP equation. Nominal current-price value added is different and contains a price contribution. Imported household energy and food are final consumption imports; subtracting them again from domestic value added would double count their subtraction. The expenditure-side identity gives the same GDP because exports finance final imports."];
text["Policy therefore uses gdp−gdpf rather than y−yf. Gross domestic production and domestic value added may respond differently to a commodity shock. Classic has sEn=0 and GDP=Y; the explicit distinction becomes necessary with the imported intermediate input."];
section["7. Derive the steady-state shares and normalisations"];
text["Set steady PD=PE=1 and steady productivity to one. The sectoral calibration combines m̄=1/ψP with X̄/Ȳ=ψP. Hence m̄X̄/Ȳ=1. These normalisations, not the exponent alone, identify an output expenditure share with the production-energy elasticity."];
eq["sEn == (PEbar Enbar)/(PDbar Ybar) == nu mbar Xbar/Ybar == nu"];
eq["KY == alpha/RKbar"];
eq["RKbar == tau/beta+delta-1"];
eq["IY == (tau+delta-1)KY"];
eq["sV == RKbar KY"];
eq["sG == govGDP(1-nu)"];
eq["sC == 1-IY-sG-nu"];
text["The rental return follows from the deterministic capital Euler condition under the source's trend convention. Balanced-growth capital accumulation implies the investment ratio. Government expenditure is a share of GDP, so its share of domestic gross output is multiplied by 1−ν. sC is total household consumption expenditure divided by domestic output, not domestic consumption quantity by itself. The utilisation coefficient is the marginal utilisation expenditure divided by output."];
eq["sNout == (1-omegaE-omegaF)sC"];
eq["sCe == omegaE sC"];
eq["sCF == omegaF sC"];
eq["sME == sEn+sCe"];
eq["sX == sME+sCF"];
eq["thetaEn == sEn/sME"];
eq["thetaCe == sCe/sME"];
eq["thetaXE == sME/sX"];
eq["thetaXF == sCF/sX"];
eq["sNout+IY+sG+sX == 1"];
text["In food calibration, cshareCF=sCF, cshareME=sME, cweightXE=θXE and cweightXF=θXF. Energy-only has ωF=0 and sME=sX; its cweightEn and cweightCe may therefore be divided by cshareX equivalently. The generators handle zero denominators, whose economic interpretation is a reduced no-import component."];
sub["7.1 The wage and the classic-model limit"];
eq["wbar == ((alpha^alpha alphaN^alphaN nu^nu)/(psiP RKbar^alpha))^(1/alphaN)"];
eq["NK == (alphaN/alpha)(RKbar/wbar)"];
text["This wage follows by imposing m̄=1/ψP in the dual cost function with unit relative energy price. At ν=0 use the reduced formula without ν^ν, interpreted by its continuous limit. The classic generator writes K/Y=ψP(N/K)^(α−1); the energy generator writes K/Y=α/R̄K. With the consistent classic wage these are algebraically equal, as verified symbolically. Their different appearances do not by themselves reveal an economic discrepancy."];
text["Require ccy>0, R̄K>0, αN>0, sGDP>0 and positive steady output. If these fail, the intended steady allocation is not admissible. Trend, units and markup/fixed-cost normalisations must remain matched in any nesting comparison."];
sub["7.2 What a calibrated share does and does not identify"];
text["A calibrated share fixes a reference allocation or parameter value; it is not automatically an estimate of a behavioural response. omegaE is a household expenditure weight, while nu is a production elasticity and a variable-cost share. Identifying nu with an energy-expenditure-to-output ratio uses the additional steady markup and fixed-cost normalisations derived above. Identifying it with an energy-to-GDP ratio would require another denominator conversion. The numerical value of the same word share therefore depends on exactly what is in the numerator and denominator."];
text["Similarly, a policy coefficient, a shock persistence and a substitution elasticity describe different mechanisms. A policy coefficient determines how the central bank reacts; a persistence coefficient determines how a disturbance evolves; an elasticity describes a conditional response inside an optimisation problem. Comparing them only as large or small numbers would obscure both units and economic meaning."];

section["8. Flexible prices, shocks and transmission channels"];
sub["8.1 Derive the flexible counterfactual consistently"];
text["Suffix f denotes the flexible-price counterfactual. Both sectoral economies face the same exogenous relative commodity prices. The flexible equations remove the sticky allocation's time-varying markup wedges, while retaining the steady markup normalisation. mc_f=0 means ZERO DEVIATION, not a zero level of marginal cost."];

text["The flexible-price allocation asks what the same economy would do if its nominal adjustment restrictions were removed under the maintained counterfactual rules. It does not remove technology, resource constraints or imported-price disturbances. Consequently, a costly energy shock can reduce the flexible allocation itself. Actual output can fall while the output gap moves little if natural output falls by a similar amount. Potential or natural output here is therefore model dependent rather than an externally observed smooth trend."];

eq["0 == alphaN wf[t]+alpha rkf[t]+nu pE[t]-a[t]"];
eq["enf[t] == yf[t]/psiP-pE[t]"];
eq["cnf[t] == cf[t]+pc[t]"];
eq["cef[t] == cf[t]+pc[t]-pE[t]"];
eq["cfoodf[t] == cf[t]+pc[t]-pF[t]"];
eq["wf[t] == pc[t]+zf[t]+epsilons[t]+omegaU nf[t]"];
text["The flexible real rate rf is measured in consumption units. Convert it to a domestic-good real rate by adding the expected change in PC/PD before discounting domestic capital returns. Since pc=0 in the classic model, the conversion is invisible there but necessary in the sectoral versions."];
eq["qf[t] == -(rf[t]+Expectation[pc[t+1],info[t]]-pc[t]-epsilonb[t])+q1 Expectation[rkf[t+1],info[t]]+(1-q1)Expectation[qf[t+1],info[t]]"];
eq["gdpf[t] == (yf[t]-sEn enf[t])/sGDP"];
eq["gap[t] == gdp[t]-gdpf[t]"];
text["The flexible resource and export-financing equations use flexible quantities, as in equations 34-36; using sticky quantities would contaminate natural output. Commodity prices can change natural GDP and actual GDP together, so the GDP response and the output-gap response need not have the same sign or magnitude. The flexible capital, investment, utilisation, employment and trend-consumption equations preserve the corresponding common block."];
sub["8.2 Commodity relative-price processes"];

text["A shock innovation is the new, unpredictable component arriving this period. A shock process includes both that innovation and the inherited effect of earlier innovations. In pE_t=rhoE pE_(t−1)+etaE_t, rhoE measures persistence and the standard deviation of etaE measures the typical innovation scale. A large one-period innovation can occur in a short-lived process, and a small innovation can have a long effect in a highly persistent process. These parameters should not be interpreted interchangeably."];
text["For a positive persistence below one, the conditional expected relative price gradually returns toward its reference. Its approximate half-life is Log[1/2]/Log[rhoE] periods, when 0<rhoE<1. The restriction is needed: the formula is not meaningful at rhoE=0 or one, and negative persistence implies alternating signs. The process is a law for a relative price, so it cannot by itself identify a structural oil-supply shock, food harvest failure or foreign-demand shock."];

eq["pE[t] == rhoE pE[t-1]+etaE[t]"];
eq["pF[t] == rhoF pF[t-1]+etaF[t]"];
text["These are reduced-form relative PRICE LEVELS in domestic currency, not commodity inflation rates. |ρ|<1 gives a stationary AR(1). The food model adds etaF and its innovation scale. Neither specification identifies whether a commodity-price innovation reflects global supply, global demand or exchange rates; there is no explicit foreign energy or agriculture supply sector or separate retail pass-through dynamics."];
text["An isolated innovation η gives p_j=ρ^jη for j≥0. Its direct CPI-inflation effect is ωη on impact and ω(ρ−1)ρ^(j−1)η thereafter. For 0<ρ<1, the later direct contribution is negative as the relative price returns to baseline. Domestic inflation and equilibrium feedback add to that component. A permanent price-level innovation at ρ=1 is not permanently higher inflation; it also changes the stationary-state interpretation."];
sub["8.3 Inherited disturbances and sign conventions"];
text["The common block contains AR(1) risk-premium, investment-efficiency, productivity, labour-supply and monetary-policy processes. Government spending has an AR(1) plus crhoga times the contemporaneous technology innovation. Price and wage markup processes are ARMA(1,1): epsilonp=crhop·epsilonp(−1)+etap−cmup·etap(−1), with the analogous wage equation. Preserve both innovation scales and the explicit factors of 100. A positive epsilonr lowers the policy rate directly; a positive epsilonp enters domestic inflation with the negative sign written in Section 4."];
section["9. The requested sequence: nesting versus recalibration"];
text["Classic to energy-food adds the consumption price basket, energy input in production, import financing, GDP double deflation, CPI-based wages and policy, two commodity-price processes, and the flexible counterparts. It is not a food-only change. Food to energy-only sets ωF=0, removes food quantities, prices, measurement variables and etaF, drops equations 61-64, removes the food term from equation 01, and reduces export-financing equations 11 and 35 to the energy-only identity. Recompute all affected shares. Technology, marginal cost and the energy-input FOC remain structurally the same."];
text["At matched common parameters, a zero food share makes a food shock irrelevant to aggregate allocations. Recovering the classic model additionally requires ν=ωE=0, removal of inactive commodity variables, consistent limiting shares and units. Then pc=0, wc=w, piC=pi, GDP=Y and import-financing exports disappear. This nesting statement is about the equations. It does not imply equality of current impulse responses across folders with different fitted parameters."];
sub["9.1 EA20 calibration snapshot"];
text["The following entries are read from the current EA20 calibration modules. They identify changes in parameter values separately from structural modifications. Food is a simulation prototype from a diagnostic energy variant, not a fresh estimation of the whole food extension."];
code["Parameter                   Classic     Energy-food    Energy-only\nch: external habit          0.635318    0.461469       0.412019\ncthetap: price rigidity      0.842802    0.750000       0.990000\ncthetaw: wage rigidity       0.696311    0.521709       0.502120\ncrpi: inflation feedback     1.287264    1.500000       0.438463\ncrhointr: rate smoothing     0.856383    0.967056       0.957115\ncrhoE: energy persistence    absent      0.966082       0.947039\ncsigmaE: energy innovation   absent      3.150063       3.171694\ncrhoF: food persistence      absent      0.800000       absent\ncsigmaF: food innovation     absent      5.000000       absent"];
text["The food README specifies illustrative food parameters, price rigidity 0.75 and inflation feedback 1.5; its main file simulates 200-quarter responses and does not execute estimation. The current energy-only file supports maximum likelihood when RUN_ESTIMATION=1; its default macro is zero and simulates the energy innovation. The classic file performs a stochastic simulation. These execution settings are not theoretical mechanisms."];
text["The energy-only rigidity close to 0.99 and inflation feedback below one are reported, not endorsed or altered here. Determinacy cannot be inferred from that feedback coefficient alone: it requires the full system's eigenvalue and rank checks at the chosen parameter vector. A controlled comparison should match common parameters, shock units, timing and size, and the sample/observables when estimating. Report structural and recalibration effects separately."];
section["10. Measurement equations and empirical interpretation"];
text["Classic measured GDP growth uses y−y(−1); sectoral versions use gdp−gdp(−1), adding the same ctaubar+cebar trend. Consumption and investment growth retain their own log differences. Classic piobs=cpibar+pi becomes sectoral piobs=cpibar+piC. The observables pEobs=pE and pFobs=pF are demeaned relative price LEVELS, not inflation series."];
code["Classic:      dyobs = ctaubar + cebar + y - y(-1);\nSectoral:     dyobs = ctaubar + cebar + gdp - gdp(-1);\nClassic:      piobs = cpibar + pi;\nSectoral:     piobs = cpibar + piC;\nAll models:   robs/4 = crbar + r;"];
text["An additional measurement change is independent of commodity theory. Classic uses dwobs−piobs=ctaubar+w−w(−1)−(pi−pi(−1)). Sectoral versions use dwobs=ctaubar+w−w(−1)+cpibar+pi. The latter is compatible with nominal wage growth when w is the domestic-real wage. Substituting classic piobs into its wage relation gives a different inflation timing. Reconcile this with the actual data before attributing likelihood differences to energy or food."];
text["The food EA20 measurement file states that no local observations are available, and the main file does not estimate. Declaring pFobs is an interface, not proof of a suitable dataset. A global agricultural index, imported food price and retail HICP food index need not measure the same object. Additional pass-through mechanisms may be needed if the selected data differ from the model's import-price concept."];
text["ryear=4r, while piyear sums four quarterly CPI-inflation deviations in the sectoral versions; piDyear sums domestic inflation. Classic sums domestic inflation because CPI equals it. Restore trend intercepts before comparing model deviations with observed rate levels. Country-specific modules may differ from the EA20 snapshot documented here."];
section["11. Boundary conditions, interpretation and exercises"];
text["Positive-domain calculations. Production requires positive productivity, prices, inputs and interior shares. Its continuous extension is zero if any essential input is zero. Holding other inputs positive and fixed, each own marginal product tends to infinity at its zero boundary and to zero at infinity. Simultaneous limits can depend on the path. Do not apply logarithms or divide by a zero input directly at the boundary."];
text["Reduced models and feasibility. Require α+ν<1 and ωE+ωF<1 in the interior model, positive habit surplus, 0<β<1, admissible depreciation and trend, and ccy>0. At a zero input or consumption share use the reduced technology/basket, not an expression containing 0/0 or 0^0. For fixed Φ, Ȳ must be positive; as Ȳ approaches zero, ψP grows and the local log approximation becomes poorly behaved."];
text["Intertemporal boundaries. Initial installed capital is predetermined. Infinite-horizon optimisation needs a debt no-Ponzi admissibility condition and an appropriate transversality condition under the selected asset and multiplier conventions. These economic restrictions differ from Dynare's local Blanchard-Kahn conditions. Neither follows from a static FOC or from the algebraic checks below."];
text["Transmission. Energy affects the consumption deflator and directly enters the firm's unit cost. Food here affects final consumption, purchasing power, policy and export financing, but does not directly enter the production cost function. The trade closure and substitution toward domestic goods can produce an initially positive GDP response; the identities do not impose its sign. The whole dynamic system must be solved. First-order local models do not automatically capture large-shock corners or nonlinear welfare effects."];
sub["Questions and short answers"];
text["1. Why en=mc+y/cpsip−pE? The FOC contains X and x=y/cpsip. 2. Why no pE in real GDP? Intermediate energy is subtracted at fixed base prices. 3. Is wc just a new label for the wage equation? Nominal wage growth is a unit identity, but CPI indexation is a policy of wage adjustment. 4. Does the final folder add production energy to the food model? No; both already have production energy, and the final folder removes food. 5. Does ωF=0 alone replicate current energy-only IRFs? Only after matching all common parameters and shock definitions. 6. Does flexible mc=0 mean zero costs? No, it means zero marginal-cost deviation around the steady markup."];
section["12. Equation map, sources and verification"];
code["Block                         Classic labels     Sectoral labels\nCPI and consumption basket     01                 01-07; food 61-64\nInvestment / capital value     02-03              08-09\nImports and resources          04                 10-12\nTechnology and factor choice   05,07,16           13-16\nDomestic price Phillips curve  06                 17\nWages/unemployment/trend       08-12              18-22\nCapital and utilisation        13-15              23-25\nPolicy and employment          17-18              26-27\nValue added                    y used as GDP      28\nFlexible counterfactual        19-31              29-47; food 62\nOutput gap                     32                 48\nEnergy-price process           absent             49\nInherited shocks               33-40              50-57\nAnnual indicators              41-42              58-60\nFood price and inflation       absent             food 63-64"];
text["Numbered labels refer to the main .mod files; measurement includes add equations separately. The source hashes below identify the exact main-file snapshot used. These model files were read only, not edited."];
Do[text[paths[[j]]<>" | core equations: "<>ToString[Length[rows[[j]]]]<>" | SHA256: "<>FileHash[paths[[j]],"SHA256","HexString"]],{j,3}];
text["Additional local sources: all three Estimation_Setup/EA20_calibration.mod, EA20_measurement.mod and EA20_shocks.mod modules; calibration/derived_parameters.py; the food folder's README.md; and the energy-only steady-state function. This is a derivation of the local specifications, not an assertion that every extension or parameter value belongs to the original published SWW model."];
sub["Symbolic and source checks"];
text["The checks cover expenditure duality, optimal input demand, Euler's production identity, marginal cost, resource-share adding up, classic capital-output equivalence, habit algebra, wage deflators, zero-food CPI reduction, and the exact food-versus-energy equation differences. They do not establish empirical fit or a stable stochastic equilibrium."];
code[StringRiffle[KeyValueMap[#1<>" : "<>ToString[#2,InputForm]&,checks],"\n"]];
displayBoxes=Cases[cells,Cell[BoxData[b_],"DisplayFormula",___]:>b,Infinity];
boxStrings=Cases[displayBoxes,s_String:>s,Infinity];
If[AnyTrue[boxStrings,StringContainsQ[#, "\""]&]||AnyTrue[boxStrings,StringContainsQ[#, "symbolPretty"|"Unevaluated"|"labelRules"]&],Print["Math typography check failed"];Exit[3]];
Print["Math typography checks: no quoted labels or unevaluated helper expressions."];
nb=Notebook[cells,StyleDefinitions->"Default.nb",WindowTitle->"SWW: energy and food derivation",WindowSize->{1150,900},ShowCellLabel->False];
nbpath=FileNameJoin[{base,"wyprowadzenie_rownan_sektora_energetycznego.nb"}];Put[nb,nbpath];
print=Notebook[cells,StyleDefinitions->"Default.nb",PrintingStyleEnvironment->"Printout",PageWidth->PaperWidth,ShowCellLabel->False,PrintingOptions->{"PaperSize"->{595.28,841.89},"PrintingMargins"->{{42,42},{42,42}},"Magnification"->1,"PrintCellBrackets"->False,"PrintMultipleHorizontalPages"->False},PageHeaders->{{None,None,None},{None,None,None}},PageFooters->{{None,Cell[TextData[{CounterBox["Page"]}],"PageNumber"],None},{None,Cell[TextData[{CounterBox["Page"]}],"PageNumber"],None}}];
print=print/.Cell[d_,"Text",___]:>Cell[d,"Text",FontFamily->"Times New Roman",FontSize->12,CellMargins->{{22,12},{7,7}},LineSpacing->{1.15,0}];
print=print/.Cell[d_,"DisplayFormula",opts___]:>Cell[d,"DisplayFormula",opts,FontSize->12,CellHorizontalScrolling->False,PageWidth->PaperWidth];
print=print/.Cell[d_,"Program",___]:>Cell[d,"Program",FontSize->9,CellHorizontalScrolling->False,PageWidth->PaperWidth];
pdf=FileNameJoin[{base,"wyprowadzenie_rownan_sektora_energetycznego.pdf"}];
Print["Checks: ",And@@Values[checks],"; equations: ",num,"; cells: ",Length[cells]];
Print["Notebook parses: ",Head[Get[nbpath]]===Notebook];
Print["PDF: ",UsingFrontEnd[Export[pdf,print,"PDF"]]];
End[];