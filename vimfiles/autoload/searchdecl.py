import re

arg1 = r'\w+\s*(\*)*'
arglist = r'%s(\s*,\s*%s\s*)*' % (arg1, arg1)
templ0 = r'\w+\s*<\s*%s\s*>' % arglist

arg2 = r'(%s|%s)' % (arg1, templ0)
arglist2 = r'%s(\s*,\s*%s\s*)*' % (arg2, arg2)
templ1 = r'\w+\s*<\s*%s\s*>' % arglist2

arg3 = r'(%s|%s)' % (arg2, templ1)
arglist3 = r'%s(\s*,\s*%s\s*)*' % (arg3, arg3)
templ2 = r'\w+\s*<\s*%s\s*>' % arglist3

# decl = r'(%s|%s)\s+' % (arg1, templ2)
decl = r'%s\s+' % arg1

expr = '''
foo bar
foo<bar*, baz> bob

void cdr_sanity_check_expressions_in_scope(CG_Scope *scope)
{
    CG_Symbol *sym;
    forEachFunctionConstInScope(sym,scope) {
        CG_Const *fcn = cg_const(sym);
        int errorCode = cg_cfg_sanity_check_expressions(cg_fcn_cfg(fcn));
        assertion_msg(errorCode==0,cdr_sanity_check_expressions_error_string(errorCode));
    }
}

void cdr_reuse_locals(CdrCtxInfo *ctxInfo, CG::Scope *scope)
{
    if(!cdr_ctx_info_coding_debug(ctxInfo)
           && !ctxInfo->options.codingForAutoVerifier
           && (sf_feature(VARIABLE_REUSE_FEATURE))) {
       if (sf_feature(COMPLETE_ASSIGNMENT_FEATURE)) {
           cg_insert_virtual_assignments_scope(scope);
       }
       cg_reuse_locals_scope(scope, sf_feature(REUSE_GLOBALS_FEATURE));
    }
}

'''

matches = re.compile(templ2).finditer(expr)
for m in matches:
    print expr[m.start(0):m.end(0)]
