/*
 * Code for class ENTITY_ALPHABET
 */

#include "eif_eiffel.h"
#include "../E1/estructure.h"


#ifdef __cplusplus
extern "C" {
#endif

extern void F965_7255(EIF_REFERENCE, EIF_TYPED_VALUE);
extern EIF_TYPED_VALUE F965_7256(EIF_REFERENCE);
extern EIF_TYPED_VALUE F965_7257(EIF_REFERENCE);
extern EIF_TYPED_VALUE F965_7258(EIF_REFERENCE, EIF_TYPED_VALUE);
extern EIF_TYPED_VALUE F965_7259(EIF_REFERENCE);
extern void F965_7878(EIF_REFERENCE, int);
extern void EIF_Minit965(void);

#ifdef __cplusplus
}
#endif

#include "eif_out.h"

#ifdef __cplusplus
extern "C" {
#endif


#ifdef __cplusplus
}
#endif


#ifdef __cplusplus
extern "C" {
#endif

/* {ENTITY_ALPHABET}.make */
void F965_7255 (EIF_REFERENCE Current, EIF_TYPED_VALUE arg1x)
{
	GTCX
	char *l_feature_name = "make";
	RTEX;
#define arg1 arg1x.it_c1
	RTCDT;
	RTSN;
	RTDA;
	RTLD;
	
	if ((arg1x.type & SK_HEAD) == SK_REF) arg1x.it_c1 = * (EIF_CHARACTER_8 *) arg1x.it_r;
	
	RTLI(1);
	RTLR(0,Current);
	RTLIU(1);
	RTLU (SK_VOID, NULL);
	RTLU(SK_CHAR8,&arg1);
	RTLU (SK_REF, &Current);
	
	RTEAA(l_feature_name, 964, Current, 0, 1, 13560);
	RTSA(dtype);
	RTSC;
	RTME(dtype, 0);
	RTGC;
	RTDBGEAA(964, Current, 13560);
	RTIV(Current, RTAL);
	RTHOOK(1);
	RTDBGAA(Current, dtype, 5045, 0x08000000, 1); /* item */
	*(EIF_CHARACTER_8 *)(Current + RTWA(5045, dtype)) = (EIF_CHARACTER_8) arg1;
	RTVI(Current, RTAL);
	RTRS;
	RTHOOK(2);
	RTDBGLE;
	RTMD(0);
	RTLE;
	RTLO(3);
	RTEE;
#undef arg1
}

/* {ENTITY_ALPHABET}.item */
EIF_TYPED_VALUE F965_7256 (EIF_REFERENCE Current)
{
	EIF_TYPED_VALUE r;
	r.type = SK_CHAR8;
	r.it_c1 = *(EIF_CHARACTER_8 *)(Current + RTWA(5045,Dtype(Current)));
	return r;
}


/* {ENTITY_ALPHABET}.out */
EIF_TYPED_VALUE F965_7257 (EIF_REFERENCE Current)
{
	GTCX
	char *l_feature_name = "out";
	RTEX;
	EIF_TYPED_VALUE up1x = {{0}, SK_POINTER};
#define up1 up1x.it_p
	EIF_REFERENCE tr1 = NULL;
	EIF_CHARACTER_8 tc1;
	EIF_REFERENCE Result = ((EIF_REFERENCE) 0);
	
	RTCDT;
	RTSN;
	RTDA;
	RTLD;
	
	RTLI(3);
	RTLR(0,Current);
	RTLR(1,tr1);
	RTLR(2,Result);
	RTLIU(3);
	RTLU (SK_REF, &Result);
	RTLU (SK_REF, &Current);
	
	RTEAA(l_feature_name, 964, Current, 0, 0, 13562);
	RTSA(dtype);
	RTSC;
	RTME(dtype, 0);
	RTGC;
	RTDBGEAA(964, Current, 13562);
	RTIV(Current, RTAL);
	RTHOOK(1);
	RTDBGAL(0, 0xF80000E8, 0,0); /* Result */
	tc1 = *(EIF_CHARACTER_8 *)(Current + RTWA(5045, dtype));
	tr1 = c_outc(tc1);
	Result = (EIF_REFERENCE) RTCCL(tr1);
	if (RTAL & CK_ENSURE) {
		RTHOOK(2);
		RTCT("out_not_void", EX_POST);
		if ((EIF_BOOLEAN)(Result != NULL)) {
			RTCK;
		} else {
			RTCF;
		}
	}
	RTVI(Current, RTAL);
	RTRS;
	RTHOOK(3);
	RTDBGLE;
	RTMD(0);
	RTLE;
	RTLO(2);
	RTEE;
	{ EIF_TYPED_VALUE r; r.type = SK_REF; r.it_r = Result; return r; }
#undef up1
}

/* {ENTITY_ALPHABET}.is_equal */
EIF_TYPED_VALUE F965_7258 (EIF_REFERENCE Current, EIF_TYPED_VALUE arg1x)
{
	GTCX
	char *l_feature_name = "is_equal";
	RTEX;
#define arg1 arg1x.it_r
	EIF_TYPED_VALUE ur1x = {{0}, SK_REF};
#define ur1 ur1x.it_r
	EIF_TYPED_VALUE uc1x = {{0}, SK_CHAR8};
#define uc1 uc1x.it_c1
	EIF_BOOLEAN tb1;
	EIF_BOOLEAN tb2;
	EIF_CHARACTER_8 tc1;
	EIF_CHARACTER_8 tc2;
	EIF_BOOLEAN Result = ((EIF_BOOLEAN) 0);
	
	RTCDT;
	RTSN;
	RTDA;
	RTLD;
	
	
	RTLI(3);
	RTLR(0,arg1);
	RTLR(1,Current);
	RTLR(2,ur1);
	RTLIU(3);
	RTLU (SK_BOOL, &Result);
	RTLU(SK_REF,&arg1);
	RTLU (SK_REF, &Current);
	
	RTEAA(l_feature_name, 964, Current, 0, 1, 13563);
	RTSA(dtype);
	RTSC;
	RTME(dtype, 0);
	RTGC;
	RTDBGEAA(964, Current, 13563);
	RTCC(arg1, 964, l_feature_name, 1, eif_new_type(964, 0x01), 0x01);
	RTIV(Current, RTAL);
	if ((RTAL & CK_REQUIRE) || RTAC) {
		RTHOOK(1);
		RTCT("other_not_void", EX_PRE);
		RTTE((EIF_BOOLEAN)(arg1 != NULL), label_1);
		RTCK;
		RTJB;
label_1:
		RTCF;
	}
body:;
	RTHOOK(2);
	RTDBGAL(0, 0x04000000, 1,0); /* Result */
	tc1 = *(EIF_CHARACTER_8 *)(Current + RTVA(5045, "item", Current));
	RTNHOOK(2,1);
	tc2 = *(EIF_CHARACTER_8 *)(arg1 + RTVA(5045, "item", arg1));
	uc1 = tc2;
	tb1 = tc1 == uc1;
	Result = (EIF_BOOLEAN) tb1;
	if (RTAL & CK_ENSURE) {
		RTHOOK(3);
		RTCT("symmetric", EX_POST);
		if ((!(Result) || (RTEQ(arg1, Current)))) {
			RTCK;
		} else {
			RTCF;
		}
		RTHOOK(4);
		RTCT("consistent", EX_POST);
		tb1 = '\01';
		ur1 = RTCCL(arg1);
		tb2 = (((FUNCTION_CAST(EIF_TYPED_VALUE, (EIF_REFERENCE, EIF_TYPED_VALUE)) RTWF(12, dtype))(Current, ur1x)).it_b);
		if (tb2) {
			tb1 = Result;
		}
		if (tb1) {
			RTCK;
		} else {
			RTCF;
		}
	}
	RTVI(Current, RTAL);
	RTRS;
	RTHOOK(5);
	RTDBGLE;
	RTMD(0);
	RTLE;
	RTLO(3);
	RTEE;
	{ EIF_TYPED_VALUE r; r.type = SK_BOOL; r.it_b = Result; return r; }
#undef ur1
#undef uc1
#undef arg1
}

/* {ENTITY_ALPHABET}.is_stationary */
EIF_TYPED_VALUE F965_7259 (EIF_REFERENCE Current)
{
	GTCX
	char *l_feature_name = "is_stationary";
	RTEX;
	EIF_CHARACTER_8 tc1;
	EIF_CHARACTER_8 tc2;
	EIF_CHARACTER_8 tc3;
	EIF_CHARACTER_8 tc4;
	EIF_BOOLEAN Result = ((EIF_BOOLEAN) 0);
	
	RTCDT;
	RTSN;
	RTDA;
	RTLD;
	
	RTLI(1);
	RTLR(0,Current);
	RTLIU(1);
	RTLU (SK_BOOL, &Result);
	RTLU (SK_REF, &Current);
	
	RTEAA(l_feature_name, 964, Current, 0, 0, 13564);
	RTSA(dtype);
	RTSC;
	RTME(dtype, 0);
	RTGC;
	RTDBGEAA(964, Current, 13564);
	RTIV(Current, RTAL);
	RTHOOK(1);
	tc1 = *(EIF_CHARACTER_8 *)(Current + RTWA(5045, dtype));
	tc2 = *(EIF_CHARACTER_8 *)(Current + RTWA(5045, dtype));
	tc3 = *(EIF_CHARACTER_8 *)(Current + RTWA(5045, dtype));
	tc4 = *(EIF_CHARACTER_8 *)(Current + RTWA(5045, dtype));
	if ((EIF_BOOLEAN) ((EIF_BOOLEAN) ((EIF_BOOLEAN) ((EIF_BOOLEAN)(tc1 == (EIF_CHARACTER_8) 'W') || (EIF_BOOLEAN)(tc2 == (EIF_CHARACTER_8) 'Y')) || (EIF_BOOLEAN)(tc3 == (EIF_CHARACTER_8) '*')) || (EIF_BOOLEAN)(tc4 == (EIF_CHARACTER_8) 'O'))) {
		RTHOOK(2);
		RTDBGAL(0, 0x04000000, 1,0); /* Result */
		Result = (EIF_BOOLEAN) (EIF_BOOLEAN) 1;
	}
	RTVI(Current, RTAL);
	RTRS;
	RTHOOK(3);
	RTDBGLE;
	RTMD(0);
	RTLE;
	RTLO(2);
	RTEE;
	{ EIF_TYPED_VALUE r; r.type = SK_BOOL; r.it_b = Result; return r; }
}

/* {ENTITY_ALPHABET}._invariant */
void F965_7878 (EIF_REFERENCE Current, int where)
{
	GTCX
	char *l_feature_name = "_invariant";
	RTEX;
	EIF_CHARACTER_8 tc1;
	EIF_CHARACTER_8 tc2;
	EIF_CHARACTER_8 tc3;
	EIF_CHARACTER_8 tc4;
	EIF_CHARACTER_8 tc5;
	EIF_CHARACTER_8 tc6;
	RTCDT;
	RTLD;
	RTDA;
	
	RTLI(1);
	RTLR(0,Current);
	RTLIU(1);
	RTLU (SK_VOID, NULL);
	RTLU (SK_REF, &Current);
	RTEAINV(l_feature_name, 964, Current, 0, 7877);
	RTSA(dtype);
	RTME(dtype, 0);
	RTIT("allowable_symbols", Current);
	tc1 = *(EIF_CHARACTER_8 *)(Current + RTWA(5045, dtype));
	tc2 = *(EIF_CHARACTER_8 *)(Current + RTWA(5045, dtype));
	tc3 = *(EIF_CHARACTER_8 *)(Current + RTWA(5045, dtype));
	tc4 = *(EIF_CHARACTER_8 *)(Current + RTWA(5045, dtype));
	tc5 = *(EIF_CHARACTER_8 *)(Current + RTWA(5045, dtype));
	tc6 = *(EIF_CHARACTER_8 *)(Current + RTWA(5045, dtype));
	if ((EIF_BOOLEAN) ((EIF_BOOLEAN) ((EIF_BOOLEAN) ((EIF_BOOLEAN) ((EIF_BOOLEAN) ((EIF_BOOLEAN)(tc1 == (EIF_CHARACTER_8) 'E') || (EIF_BOOLEAN)(tc2 == (EIF_CHARACTER_8) 'P')) || (EIF_BOOLEAN)(tc3 == (EIF_CHARACTER_8) 'O')) || (EIF_BOOLEAN)(tc4 == (EIF_CHARACTER_8) 'W')) || (EIF_BOOLEAN)(tc5 == (EIF_CHARACTER_8) 'Y')) || (EIF_BOOLEAN)(tc6 == (EIF_CHARACTER_8) '*'))) {
		RTCK;
	} else {
		RTCF;
	}
	RTLO(2);
	RTMD(0);
	RTLE;
	RTEE;
}

void EIF_Minit965 (void)
{
	GTCX
}


#ifdef __cplusplus
}
#endif
