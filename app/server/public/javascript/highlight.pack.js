/*!
  Highlight.js v11.0.1 (git: 1cf31f015d)
  (c) 2006-2021 Ivan Sagalaev and other contributors
  License: BSD-3-Clause
 */
  var hljs=function(){"use strict";var e={exports:{}};function t(e){
    return e instanceof Map?e.clear=e.delete=e.set=()=>{
    throw Error("map is read-only")}:e instanceof Set&&(e.add=e.clear=e.delete=()=>{
    throw Error("set is read-only")
    }),Object.freeze(e),Object.getOwnPropertyNames(e).forEach((n=>{var i=e[n]
    ;"object"!=typeof i||Object.isFrozen(i)||t(i)})),e}
    e.exports=t,e.exports.default=t;var n=e.exports;class i{constructor(e){
    void 0===e.data&&(e.data={}),this.data=e.data,this.isMatchIgnored=!1}
    ignoreMatch(){this.isMatchIgnored=!0}}function r(e){
    return e.replace(/&/g,"&amp;").replace(/</g,"&lt;").replace(/>/g,"&gt;").replace(/"/g,"&quot;").replace(/'/g,"&#x27;")
    }function s(e,...t){const n=Object.create(null);for(const t in e)n[t]=e[t]
    ;return t.forEach((e=>{for(const t in e)n[t]=e[t]})),n}const o=e=>!!e.kind
    ;class a{constructor(e,t){
    this.buffer="",this.classPrefix=t.classPrefix,e.walk(this)}addText(e){
    this.buffer+=r(e)}openNode(e){if(!o(e))return;let t=e.kind
    ;t=e.sublanguage?"language-"+t:((e,{prefix:t})=>{if(e.includes(".")){
    const n=e.split(".")
    ;return[`${t}${n.shift()}`,...n.map(((e,t)=>`${e}${"_".repeat(t+1)}`))].join(" ")
    }return`${t}${e}`})(t,{prefix:this.classPrefix}),this.span(t)}closeNode(e){
    o(e)&&(this.buffer+="</span>")}value(){return this.buffer}span(e){
    this.buffer+=`<span class="${e}">`}}class l{constructor(){this.rootNode={
    children:[]},this.stack=[this.rootNode]}get top(){
    return this.stack[this.stack.length-1]}get root(){return this.rootNode}add(e){
    this.top.children.push(e)}openNode(e){const t={kind:e,children:[]}
    ;this.add(t),this.stack.push(t)}closeNode(){
    if(this.stack.length>1)return this.stack.pop()}closeAllNodes(){
    for(;this.closeNode(););}toJSON(){return JSON.stringify(this.rootNode,null,4)}
    walk(e){return this.constructor._walk(e,this.rootNode)}static _walk(e,t){
    return"string"==typeof t?e.addText(t):t.children&&(e.openNode(t),
    t.children.forEach((t=>this._walk(e,t))),e.closeNode(t)),e}static _collapse(e){
    "string"!=typeof e&&e.children&&(e.children.every((e=>"string"==typeof e))?e.children=[e.children.join("")]:e.children.forEach((e=>{
    l._collapse(e)})))}}class c extends l{constructor(e){super(),this.options=e}
    addKeyword(e,t){""!==e&&(this.openNode(t),this.addText(e),this.closeNode())}
    addText(e){""!==e&&this.add(e)}addSublanguage(e,t){const n=e.root
    ;n.kind=t,n.sublanguage=!0,this.add(n)}toHTML(){
    return new a(this,this.options).value()}finalize(){return!0}}function g(e){
    return e?"string"==typeof e?e:e.source:null}function d(...e){
    return e.map((e=>g(e))).join("")}function u(...e){return"("+((e=>{
    const t=e[e.length-1]
    ;return"object"==typeof t&&t.constructor===Object?(e.splice(e.length-1,1),t):{}
    })(e).capture?"":"?:")+e.map((e=>g(e))).join("|")+")"}function h(e){
    return RegExp(e.toString()+"|").exec("").length-1}
    const f=/\[(?:[^\\\]]|\\.)*\]|\(\??|\\([1-9][0-9]*)|\\./
    ;function p(e,{joinWith:t}){let n=0;return e.map((e=>{n+=1;const t=n
    ;let i=g(e),r="";for(;i.length>0;){const e=f.exec(i);if(!e){r+=i;break}
    r+=i.substring(0,e.index),
    i=i.substring(e.index+e[0].length),"\\"===e[0][0]&&e[1]?r+="\\"+(Number(e[1])+t):(r+=e[0],
    "("===e[0]&&n++)}return r})).map((e=>`(${e})`)).join(t)}
    const b="[a-zA-Z]\\w*",m="[a-zA-Z_]\\w*",E="\\b\\d+(\\.\\d+)?",x="(-?)(\\b0[xX][a-fA-F0-9]+|(\\b\\d+(\\.\\d*)?|\\.\\d+)([eE][-+]?\\d+)?)",y="\\b(0b[01]+)",w={
    begin:"\\\\[\\s\\S]",relevance:0},_={scope:"string",begin:"'",end:"'",
    illegal:"\\n",contains:[w]},v={scope:"string",begin:'"',end:'"',illegal:"\\n",
    contains:[w]},O=(e,t,n={})=>{const i=s({scope:"comment",begin:e,end:t,
    contains:[]},n);i.contains.push({scope:"doctag",
    begin:"[ ]*(?=(TODO|FIXME|NOTE|BUG|OPTIMIZE|HACK|XXX):)",
    end:/(TODO|FIXME|NOTE|BUG|OPTIMIZE|HACK|XXX):/,excludeBegin:!0,relevance:0})
    ;const r=u("I","a","is","so","us","to","at","if","in","it","on",/[A-Za-z]+['](d|ve|re|ll|t|s|n)/,/[A-Za-z]+[-][a-z]+/,/[A-Za-z][a-z]{2,}/)
    ;return i.contains.push({begin:d(/[ ]+/,"(",r,/[.]?[:]?([.][ ]|[ ])/,"){3}")}),i
    },k=O("//","$"),N=O("/\\*","\\*/"),S=O("#","$");var M=Object.freeze({
    __proto__:null,MATCH_NOTHING_RE:/\b\B/,IDENT_RE:b,UNDERSCORE_IDENT_RE:m,
    NUMBER_RE:E,C_NUMBER_RE:x,BINARY_NUMBER_RE:y,
    RE_STARTERS_RE:"!|!=|!==|%|%=|&|&&|&=|\\*|\\*=|\\+|\\+=|,|-|-=|/=|/|:|;|<<|<<=|<=|<|===|==|=|>>>=|>>=|>=|>>>|>>|>|\\?|\\[|\\{|\\(|\\^|\\^=|\\||\\|=|\\|\\||~",
    SHEBANG:(e={})=>{const t=/^#![ ]*\//
    ;return e.binary&&(e.begin=d(t,/.*\b/,e.binary,/\b.*/)),s({scope:"meta",begin:t,
    end:/$/,relevance:0,"on:begin":(e,t)=>{0!==e.index&&t.ignoreMatch()}},e)},
    BACKSLASH_ESCAPE:w,APOS_STRING_MODE:_,QUOTE_STRING_MODE:v,PHRASAL_WORDS_MODE:{
    begin:/\b(a|an|the|are|I'm|isn't|don't|doesn't|won't|but|just|should|pretty|simply|enough|gonna|going|wtf|so|such|will|you|your|they|like|more)\b/
    },COMMENT:O,C_LINE_COMMENT_MODE:k,C_BLOCK_COMMENT_MODE:N,HASH_COMMENT_MODE:S,
    NUMBER_MODE:{scope:"number",begin:E,relevance:0},C_NUMBER_MODE:{scope:"number",
    begin:x,relevance:0},BINARY_NUMBER_MODE:{scope:"number",begin:y,relevance:0},
    REGEXP_MODE:{begin:/(?=\/[^/\n]*\/)/,contains:[{scope:"regexp",begin:/\//,
    end:/\/[gimuy]*/,illegal:/\n/,contains:[w,{begin:/\[/,end:/\]/,relevance:0,
    contains:[w]}]}]},TITLE_MODE:{scope:"title",begin:b,relevance:0},
    UNDERSCORE_TITLE_MODE:{scope:"title",begin:m,relevance:0},METHOD_GUARD:{
    begin:"\\.\\s*[a-zA-Z_]\\w*",relevance:0},END_SAME_AS_BEGIN:e=>Object.assign(e,{
    "on:begin":(e,t)=>{t.data._beginMatch=e[1]},"on:end":(e,t)=>{
    t.data._beginMatch!==e[1]&&t.ignoreMatch()}})});function R(e,t){
    "."===e.input[e.index-1]&&t.ignoreMatch()}function j(e,t){
    void 0!==e.className&&(e.scope=e.className,delete e.className)}function A(e,t){
    t&&e.beginKeywords&&(e.begin="\\b("+e.beginKeywords.split(" ").join("|")+")(?!\\.)(?=\\b|\\s)",
    e.__beforeBegin=R,e.keywords=e.keywords||e.beginKeywords,delete e.beginKeywords,
    void 0===e.relevance&&(e.relevance=0))}function I(e,t){
    Array.isArray(e.illegal)&&(e.illegal=u(...e.illegal))}function B(e,t){
    if(e.match){
    if(e.begin||e.end)throw Error("begin & end are not supported with match")
    ;e.begin=e.match,delete e.match}}function T(e,t){
    void 0===e.relevance&&(e.relevance=1)}const L=(e,t)=>{if(!e.beforeMatch)return
    ;if(e.starts)throw Error("beforeMatch cannot be used with starts")
    ;const n=Object.assign({},e);Object.keys(e).forEach((t=>{delete e[t]
    })),e.keywords=n.keywords,
    e.begin=d(n.beforeMatch,d("(?=",n.begin,")")),e.starts={relevance:0,
    contains:[Object.assign(n,{endsParent:!0})]},e.relevance=0,delete n.beforeMatch
    },D=["of","and","for","in","not","or","if","then","parent","list","value"]
    ;function P(e,t,n="keyword"){const i=Object.create(null)
    ;return"string"==typeof e?r(n,e.split(" ")):Array.isArray(e)?r(n,e):Object.keys(e).forEach((n=>{
    Object.assign(i,P(e[n],t,n))})),i;function r(e,n){
    t&&(n=n.map((e=>e.toLowerCase()))),n.forEach((t=>{const n=t.split("|")
    ;i[n[0]]=[e,C(n[0],n[1])]}))}}function C(e,t){
    return t?Number(t):(e=>D.includes(e.toLowerCase()))(e)?0:1}const H={},$=e=>{
    console.error(e)},U=(e,...t)=>{console.log("WARN: "+e,...t)},z=(e,t)=>{
    H[`${e}/${t}`]||(console.log(`Deprecated as of ${e}. ${t}`),H[`${e}/${t}`]=!0)
    },K=Error();function W(e,t,{key:n}){let i=0;const r=e[n],s={},o={}
    ;for(let e=1;e<=t.length;e++)o[e+i]=r[e],s[e+i]=!0,i+=h(t[e-1])
    ;e[n]=o,e[n]._emit=s,e[n]._multi=!0}function X(e){(e=>{
    e.scope&&"object"==typeof e.scope&&null!==e.scope&&(e.beginScope=e.scope,
    delete e.scope)})(e),"string"==typeof e.beginScope&&(e.beginScope={
    _wrap:e.beginScope}),"string"==typeof e.endScope&&(e.endScope={_wrap:e.endScope
    }),(e=>{if(Array.isArray(e.begin)){
    if(e.skip||e.excludeBegin||e.returnBegin)throw $("skip, excludeBegin, returnBegin not compatible with beginScope: {}"),
    K
    ;if("object"!=typeof e.beginScope||null===e.beginScope)throw $("beginScope must be object"),
    K;W(e,e.begin,{key:"beginScope"}),e.begin=p(e.begin,{joinWith:""})}})(e),(e=>{
    if(Array.isArray(e.end)){
    if(e.skip||e.excludeEnd||e.returnEnd)throw $("skip, excludeEnd, returnEnd not compatible with endScope: {}"),
    K
    ;if("object"!=typeof e.endScope||null===e.endScope)throw $("endScope must be object"),
    K;W(e,e.end,{key:"endScope"}),e.end=p(e.end,{joinWith:""})}})(e)}function G(e){
    function t(t,n){return RegExp(g(t),"m"+(e.case_insensitive?"i":"")+(n?"g":""))}
    class n{constructor(){
    this.matchIndexes={},this.regexes=[],this.matchAt=1,this.position=0}
    addRule(e,t){
    t.position=this.position++,this.matchIndexes[this.matchAt]=t,this.regexes.push([t,e]),
    this.matchAt+=h(e)+1}compile(){0===this.regexes.length&&(this.exec=()=>null)
    ;const e=this.regexes.map((e=>e[1]));this.matcherRe=t(p(e,{joinWith:"|"
    }),!0),this.lastIndex=0}exec(e){this.matcherRe.lastIndex=this.lastIndex
    ;const t=this.matcherRe.exec(e);if(!t)return null
    ;const n=t.findIndex(((e,t)=>t>0&&void 0!==e)),i=this.matchIndexes[n]
    ;return t.splice(0,n),Object.assign(t,i)}}class i{constructor(){
    this.rules=[],this.multiRegexes=[],
    this.count=0,this.lastIndex=0,this.regexIndex=0}getMatcher(e){
    if(this.multiRegexes[e])return this.multiRegexes[e];const t=new n
    ;return this.rules.slice(e).forEach((([e,n])=>t.addRule(e,n))),
    t.compile(),this.multiRegexes[e]=t,t}resumingScanAtSamePosition(){
    return 0!==this.regexIndex}considerAll(){this.regexIndex=0}addRule(e,t){
    this.rules.push([e,t]),"begin"===t.type&&this.count++}exec(e){
    const t=this.getMatcher(this.regexIndex);t.lastIndex=this.lastIndex
    ;let n=t.exec(e)
    ;if(this.resumingScanAtSamePosition())if(n&&n.index===this.lastIndex);else{
    const t=this.getMatcher(0);t.lastIndex=this.lastIndex+1,n=t.exec(e)}
    return n&&(this.regexIndex+=n.position+1,
    this.regexIndex===this.count&&this.considerAll()),n}}
    if(e.compilerExtensions||(e.compilerExtensions=[]),
    e.contains&&e.contains.includes("self"))throw Error("ERR: contains `self` is not supported at the top-level of a language.  See documentation.")
    ;return e.classNameAliases=s(e.classNameAliases||{}),function n(r,o){const a=r
    ;if(r.isCompiled)return a
    ;[j,B,X,L].forEach((e=>e(r,o))),e.compilerExtensions.forEach((e=>e(r,o))),
    r.__beforeBegin=null,[A,I,T].forEach((e=>e(r,o))),r.isCompiled=!0;let l=null
    ;return"object"==typeof r.keywords&&r.keywords.$pattern&&(r.keywords=Object.assign({},r.keywords),
    l=r.keywords.$pattern,
    delete r.keywords.$pattern),l=l||/\w+/,r.keywords&&(r.keywords=P(r.keywords,e.case_insensitive)),
    a.keywordPatternRe=t(l,!0),
    o&&(r.begin||(r.begin=/\B|\b/),a.beginRe=t(r.begin),r.end||r.endsWithParent||(r.end=/\B|\b/),
    r.end&&(a.endRe=t(r.end)),
    a.terminatorEnd=g(r.end)||"",r.endsWithParent&&o.terminatorEnd&&(a.terminatorEnd+=(r.end?"|":"")+o.terminatorEnd)),
    r.illegal&&(a.illegalRe=t(r.illegal)),
    r.contains||(r.contains=[]),r.contains=[].concat(...r.contains.map((e=>(e=>(e.variants&&!e.cachedVariants&&(e.cachedVariants=e.variants.map((t=>s(e,{
    variants:null},t)))),e.cachedVariants?e.cachedVariants:Z(e)?s(e,{
    starts:e.starts?s(e.starts):null
    }):Object.isFrozen(e)?s(e):e))("self"===e?r:e)))),r.contains.forEach((e=>{n(e,a)
    })),r.starts&&n(r.starts,o),a.matcher=(e=>{const t=new i
    ;return e.contains.forEach((e=>t.addRule(e.begin,{rule:e,type:"begin"
    }))),e.terminatorEnd&&t.addRule(e.terminatorEnd,{type:"end"
    }),e.illegal&&t.addRule(e.illegal,{type:"illegal"}),t})(a),a}(e)}function Z(e){
    return!!e&&(e.endsWithParent||Z(e.starts))}const F=r,V=s,q=Symbol("nomatch")
    ;var J=(e=>{const t=Object.create(null),r=Object.create(null),s=[];let o=!0
    ;const a="Could not find the language '{}', did you forget to load/include a language module?",l={
    disableAutodetect:!0,name:"Plain text",contains:[]};let g={
    ignoreUnescapedHTML:!1,noHighlightRe:/^(no-?highlight)$/i,
    languageDetectRe:/\blang(?:uage)?-([\w-]+)\b/i,classPrefix:"hljs-",
    cssSelector:"pre code",languages:null,__emitter:c};function d(e){
    return g.noHighlightRe.test(e)}function u(e,t,n,i){let r="",s=""
    ;"object"==typeof t?(r=e,
    n=t.ignoreIllegals,s=t.language,i=void 0):(z("10.7.0","highlight(lang, code, ...args) has been deprecated."),
    z("10.7.0","Please use highlight(code, options) instead.\nhttps://github.com/highlightjs/highlight.js/issues/2277"),
    s=e,r=t),void 0===n&&(n=!0);const o={code:r,language:s};w("before:highlight",o)
    ;const a=o.result?o.result:h(o.language,o.code,n,i)
    ;return a.code=o.code,w("after:highlight",a),a}function h(e,n,r,s){
    const l=Object.create(null);function c(){if(!k.keywords)return void S.addText(M)
    ;let e=0;k.keywordPatternRe.lastIndex=0;let t=k.keywordPatternRe.exec(M),n=""
    ;for(;t;){n+=M.substring(e,t.index)
    ;const r=_.case_insensitive?t[0].toLowerCase():t[0],s=(i=r,k.keywords[i]);if(s){
    const[e,i]=s
    ;if(S.addText(n),n="",l[r]=(l[r]||0)+1,l[r]<=7&&(R+=i),e.startsWith("_"))n+=t[0];else{
    const n=_.classNameAliases[e]||e;S.addKeyword(t[0],n)}}else n+=t[0]
    ;e=k.keywordPatternRe.lastIndex,t=k.keywordPatternRe.exec(M)}var i
    ;n+=M.substr(e),S.addText(n)}function d(){null!=k.subLanguage?(()=>{
    if(""===M)return;let e=null;if("string"==typeof k.subLanguage){
    if(!t[k.subLanguage])return void S.addText(M)
    ;e=h(k.subLanguage,M,!0,N[k.subLanguage]),N[k.subLanguage]=e._top
    }else e=f(M,k.subLanguage.length?k.subLanguage:null)
    ;k.relevance>0&&(R+=e.relevance),S.addSublanguage(e._emitter,e.language)
    })():c(),M=""}function u(e,t){let n=1;for(;void 0!==t[n];){if(!e._emit[n]){n++
    ;continue}const i=_.classNameAliases[e[n]]||e[n],r=t[n]
    ;i?S.addKeyword(r,i):(M=r,c(),M=""),n++}}function p(e,t){
    return e.scope&&"string"==typeof e.scope&&S.openNode(_.classNameAliases[e.scope]||e.scope),
    e.beginScope&&(e.beginScope._wrap?(S.addKeyword(M,_.classNameAliases[e.beginScope._wrap]||e.beginScope._wrap),
    M=""):e.beginScope._multi&&(u(e.beginScope,t),M="")),k=Object.create(e,{parent:{
    value:k}}),k}function b(e,t,n){let r=((e,t)=>{const n=e&&e.exec(t)
    ;return n&&0===n.index})(e.endRe,n);if(r){if(e["on:end"]){const n=new i(e)
    ;e["on:end"](t,n),n.isMatchIgnored&&(r=!1)}if(r){
    for(;e.endsParent&&e.parent;)e=e.parent;return e}}
    if(e.endsWithParent)return b(e.parent,t,n)}function m(e){
    return 0===k.matcher.regexIndex?(M+=e[0],1):(I=!0,0)}function x(e){
    const t=e[0],i=n.substr(e.index),r=b(k,e,i);if(!r)return q;const s=k
    ;k.endScope&&k.endScope._wrap?(d(),
    S.addKeyword(t,k.endScope._wrap)):k.endScope&&k.endScope._multi?(d(),
    u(k.endScope,e)):s.skip?M+=t:(s.returnEnd||s.excludeEnd||(M+=t),
    d(),s.excludeEnd&&(M=t));do{
    k.scope&&!k.isMultiClass&&S.closeNode(),k.skip||k.subLanguage||(R+=k.relevance),
    k=k.parent}while(k!==r.parent)
    ;return r.starts&&p(r.starts,e),s.returnEnd?0:t.length}let y={};function w(t,s){
    const a=s&&s[0];if(M+=t,null==a)return d(),0
    ;if("begin"===y.type&&"end"===s.type&&y.index===s.index&&""===a){
    if(M+=n.slice(s.index,s.index+1),!o){const t=Error(`0 width match regex (${e})`)
    ;throw t.languageName=e,t.badRule=y.rule,t}return 1}
    if(y=s,"begin"===s.type)return(e=>{
    const t=e[0],n=e.rule,r=new i(n),s=[n.__beforeBegin,n["on:begin"]]
    ;for(const n of s)if(n&&(n(e,r),r.isMatchIgnored))return m(t)
    ;return n.skip?M+=t:(n.excludeBegin&&(M+=t),
    d(),n.returnBegin||n.excludeBegin||(M=t)),p(n,e),n.returnBegin?0:t.length})(s)
    ;if("illegal"===s.type&&!r){
    const e=Error('Illegal lexeme "'+a+'" for mode "'+(k.scope||"<unnamed>")+'"')
    ;throw e.mode=k,e}if("end"===s.type){const e=x(s);if(e!==q)return e}
    if("illegal"===s.type&&""===a)return 1
    ;if(A>1e5&&A>3*s.index)throw Error("potential infinite loop, way more iterations than matches")
    ;return M+=a,a.length}const _=E(e)
    ;if(!_)throw $(a.replace("{}",e)),Error('Unknown language: "'+e+'"')
    ;const v=G(_);let O="",k=s||v;const N={},S=new g.__emitter(g);(()=>{const e=[]
    ;for(let t=k;t!==_;t=t.parent)t.scope&&e.unshift(t.scope)
    ;e.forEach((e=>S.openNode(e)))})();let M="",R=0,j=0,A=0,I=!1;try{
    for(k.matcher.considerAll();;){
    A++,I?I=!1:k.matcher.considerAll(),k.matcher.lastIndex=j
    ;const e=k.matcher.exec(n);if(!e)break;const t=w(n.substring(j,e.index),e)
    ;j=e.index+t}return w(n.substr(j)),S.closeAllNodes(),S.finalize(),O=S.toHTML(),{
    language:e,value:O,relevance:R,illegal:!1,_emitter:S,_top:k}}catch(t){
    if(t.message&&t.message.includes("Illegal"))return{language:e,value:F(n),
    illegal:!0,relevance:0,_illegalBy:{message:t.message,index:j,
    context:n.slice(j-100,j+100),mode:t.mode,resultSoFar:O},_emitter:S};if(o)return{
    language:e,value:F(n),illegal:!1,relevance:0,errorRaised:t,_emitter:S,_top:k}
    ;throw t}}function f(e,n){n=n||g.languages||Object.keys(t);const i=(e=>{
    const t={value:F(e),illegal:!1,relevance:0,_top:l,_emitter:new g.__emitter(g)}
    ;return t._emitter.addText(e),t})(e),r=n.filter(E).filter(y).map((t=>h(t,e,!1)))
    ;r.unshift(i);const s=r.sort(((e,t)=>{
    if(e.relevance!==t.relevance)return t.relevance-e.relevance
    ;if(e.language&&t.language){if(E(e.language).supersetOf===t.language)return 1
    ;if(E(t.language).supersetOf===e.language)return-1}return 0})),[o,a]=s,c=o
    ;return c.secondBest=a,c}function p(e){let t=null;const n=(e=>{
    let t=e.className+" ";t+=e.parentNode?e.parentNode.className:""
    ;const n=g.languageDetectRe.exec(t);if(n){const t=E(n[1])
    ;return t||(U(a.replace("{}",n[1])),
    U("Falling back to no-highlight mode for this block.",e)),t?n[1]:"no-highlight"}
    return t.split(/\s+/).find((e=>d(e)||E(e)))})(e);if(d(n))return
    ;w("before:highlightElement",{el:e,language:n
    }),!g.ignoreUnescapedHTML&&e.children.length>0&&(console.warn("One of your code blocks includes unescaped HTML. This is a potentially serious security risk."),
    console.warn("https://github.com/highlightjs/highlight.js/issues/2886"),
    console.warn(e)),t=e;const i=t.textContent,s=n?u(i,{language:n,ignoreIllegals:!0
    }):f(i);e.innerHTML=s.value,((e,t,n)=>{const i=t&&r[t]||n
    ;e.classList.add("hljs"),e.classList.add("language-"+i)
    })(e,n,s.language),e.result={language:s.language,re:s.relevance,
    relevance:s.relevance},s.secondBest&&(e.secondBest={
    language:s.secondBest.language,relevance:s.secondBest.relevance
    }),w("after:highlightElement",{el:e,result:s,text:i})}let b=!1;function m(){
    "loading"!==document.readyState?document.querySelectorAll(g.cssSelector).forEach(p):b=!0
    }function E(e){return e=(e||"").toLowerCase(),t[e]||t[r[e]]}
    function x(e,{languageName:t}){"string"==typeof e&&(e=[e]),e.forEach((e=>{
    r[e.toLowerCase()]=t}))}function y(e){const t=E(e)
    ;return t&&!t.disableAutodetect}function w(e,t){const n=e;s.forEach((e=>{
    e[n]&&e[n](t)}))}
    "undefined"!=typeof window&&window.addEventListener&&window.addEventListener("DOMContentLoaded",(()=>{
    b&&m()}),!1),Object.assign(e,{highlight:u,highlightAuto:f,highlightAll:m,
    highlightElement:p,
    highlightBlock:e=>(z("10.7.0","highlightBlock will be removed entirely in v12.0"),
    z("10.7.0","Please use highlightElement now."),p(e)),configure:e=>{g=V(g,e)},
    initHighlighting:()=>{
    m(),z("10.6.0","initHighlighting() deprecated.  Use highlightAll() now.")},
    initHighlightingOnLoad:()=>{
    m(),z("10.6.0","initHighlightingOnLoad() deprecated.  Use highlightAll() now.")
    },registerLanguage:(n,i)=>{let r=null;try{r=i(e)}catch(e){
    if($("Language definition for '{}' could not be registered.".replace("{}",n)),
    !o)throw e;$(e),r=l}
    r.name||(r.name=n),t[n]=r,r.rawDefinition=i.bind(null,e),r.aliases&&x(r.aliases,{
    languageName:n})},unregisterLanguage:e=>{delete t[e]
    ;for(const t of Object.keys(r))r[t]===e&&delete r[t]},
    listLanguages:()=>Object.keys(t),getLanguage:E,registerAliases:x,
    autoDetection:y,inherit:V,addPlugin:e=>{(e=>{
    e["before:highlightBlock"]&&!e["before:highlightElement"]&&(e["before:highlightElement"]=t=>{
    e["before:highlightBlock"](Object.assign({block:t.el},t))
    }),e["after:highlightBlock"]&&!e["after:highlightElement"]&&(e["after:highlightElement"]=t=>{
    e["after:highlightBlock"](Object.assign({block:t.el},t))})})(e),s.push(e)}
    }),e.debugMode=()=>{o=!1},e.safeMode=()=>{o=!0},e.versionString="11.0.1"
    ;for(const e in M)"object"==typeof M[e]&&n(M[e]);return Object.assign(e,M),e
    })({}),Y=Object.freeze({__proto__:null});const Q=J
    ;for(const e of Object.keys(Y)){const t=e.replace("grmr_","")
    ;Q.registerLanguage(t,Y[e])}return Q}()
    ;"object"==typeof exports&&"undefined"!=typeof module&&(module.exports=hljs);hljs.registerLanguage("scss",(()=>{"use strict"
    ;const e=["a","abbr","address","article","aside","audio","b","blockquote","body","button","canvas","caption","cite","code","dd","del","details","dfn","div","dl","dt","em","fieldset","figcaption","figure","footer","form","h1","h2","h3","h4","h5","h6","header","hgroup","html","i","iframe","img","input","ins","kbd","label","legend","li","main","mark","menu","nav","object","ol","p","q","quote","samp","section","span","strong","summary","sup","table","tbody","td","textarea","tfoot","th","thead","time","tr","ul","var","video"],t=["any-hover","any-pointer","aspect-ratio","color","color-gamut","color-index","device-aspect-ratio","device-height","device-width","display-mode","forced-colors","grid","height","hover","inverted-colors","monochrome","orientation","overflow-block","overflow-inline","pointer","prefers-color-scheme","prefers-contrast","prefers-reduced-motion","prefers-reduced-transparency","resolution","scan","scripting","update","width","min-width","max-width","min-height","max-height"],i=["active","any-link","blank","checked","current","default","defined","dir","disabled","drop","empty","enabled","first","first-child","first-of-type","fullscreen","future","focus","focus-visible","focus-within","has","host","host-context","hover","indeterminate","in-range","invalid","is","lang","last-child","last-of-type","left","link","local-link","not","nth-child","nth-col","nth-last-child","nth-last-col","nth-last-of-type","nth-of-type","only-child","only-of-type","optional","out-of-range","past","placeholder-shown","read-only","read-write","required","right","root","scope","target","target-within","user-invalid","valid","visited","where"],r=["after","backdrop","before","cue","cue-region","first-letter","first-line","grammar-error","marker","part","placeholder","selection","slotted","spelling-error"],o=["align-content","align-items","align-self","animation","animation-delay","animation-direction","animation-duration","animation-fill-mode","animation-iteration-count","animation-name","animation-play-state","animation-timing-function","auto","backface-visibility","background","background-attachment","background-clip","background-color","background-image","background-origin","background-position","background-repeat","background-size","border","border-bottom","border-bottom-color","border-bottom-left-radius","border-bottom-right-radius","border-bottom-style","border-bottom-width","border-collapse","border-color","border-image","border-image-outset","border-image-repeat","border-image-slice","border-image-source","border-image-width","border-left","border-left-color","border-left-style","border-left-width","border-radius","border-right","border-right-color","border-right-style","border-right-width","border-spacing","border-style","border-top","border-top-color","border-top-left-radius","border-top-right-radius","border-top-style","border-top-width","border-width","bottom","box-decoration-break","box-shadow","box-sizing","break-after","break-before","break-inside","caption-side","clear","clip","clip-path","color","column-count","column-fill","column-gap","column-rule","column-rule-color","column-rule-style","column-rule-width","column-span","column-width","columns","content","counter-increment","counter-reset","cursor","direction","display","empty-cells","filter","flex","flex-basis","flex-direction","flex-flow","flex-grow","flex-shrink","flex-wrap","float","font","font-display","font-family","font-feature-settings","font-kerning","font-language-override","font-size","font-size-adjust","font-smoothing","font-stretch","font-style","font-variant","font-variant-ligatures","font-variation-settings","font-weight","height","hyphens","icon","image-orientation","image-rendering","image-resolution","ime-mode","inherit","initial","justify-content","left","letter-spacing","line-height","list-style","list-style-image","list-style-position","list-style-type","margin","margin-bottom","margin-left","margin-right","margin-top","marks","mask","max-height","max-width","min-height","min-width","nav-down","nav-index","nav-left","nav-right","nav-up","none","normal","object-fit","object-position","opacity","order","orphans","outline","outline-color","outline-offset","outline-style","outline-width","overflow","overflow-wrap","overflow-x","overflow-y","padding","padding-bottom","padding-left","padding-right","padding-top","page-break-after","page-break-before","page-break-inside","perspective","perspective-origin","pointer-events","position","quotes","resize","right","src","tab-size","table-layout","text-align","text-align-last","text-decoration","text-decoration-color","text-decoration-line","text-decoration-style","text-indent","text-overflow","text-rendering","text-shadow","text-transform","text-underline-position","top","transform","transform-origin","transform-style","transition","transition-delay","transition-duration","transition-property","transition-timing-function","unicode-bidi","vertical-align","visibility","white-space","widows","width","word-break","word-spacing","word-wrap","z-index"].reverse()
    ;return a=>{const n=(e=>({IMPORTANT:{scope:"meta",begin:"!important"},HEXCOLOR:{
    scope:"number",begin:"#([a-fA-F0-9]{6}|[a-fA-F0-9]{3})"},
    ATTRIBUTE_SELECTOR_MODE:{scope:"selector-attr",begin:/\[/,end:/\]/,illegal:"$",
    contains:[e.APOS_STRING_MODE,e.QUOTE_STRING_MODE]},CSS_NUMBER_MODE:{
    scope:"number",
    begin:e.NUMBER_RE+"(%|em|ex|ch|rem|vw|vh|vmin|vmax|cm|mm|in|pt|pc|px|deg|grad|rad|turn|s|ms|Hz|kHz|dpi|dpcm|dppx)?",
    relevance:0}}))(a),l=r,s=i,d="@[a-z-]+",c={className:"variable",
    begin:"(\\$[a-zA-Z-][a-zA-Z0-9_-]*)\\b"};return{name:"SCSS",case_insensitive:!0,
    illegal:"[=/|']",contains:[a.C_LINE_COMMENT_MODE,a.C_BLOCK_COMMENT_MODE,{
    className:"selector-id",begin:"#[A-Za-z0-9_-]+",relevance:0},{
    className:"selector-class",begin:"\\.[A-Za-z0-9_-]+",relevance:0
    },n.ATTRIBUTE_SELECTOR_MODE,{className:"selector-tag",
    begin:"\\b("+e.join("|")+")\\b",relevance:0},{className:"selector-pseudo",
    begin:":("+s.join("|")+")"},{className:"selector-pseudo",
    begin:"::("+l.join("|")+")"},c,{begin:/\(/,end:/\)/,contains:[n.CSS_NUMBER_MODE]
    },{className:"attribute",begin:"\\b("+o.join("|")+")\\b"},{
    begin:"\\b(whitespace|wait|w-resize|visible|vertical-text|vertical-ideographic|uppercase|upper-roman|upper-alpha|underline|transparent|top|thin|thick|text|text-top|text-bottom|tb-rl|table-header-group|table-footer-group|sw-resize|super|strict|static|square|solid|small-caps|separate|se-resize|scroll|s-resize|rtl|row-resize|ridge|right|repeat|repeat-y|repeat-x|relative|progress|pointer|overline|outside|outset|oblique|nowrap|not-allowed|normal|none|nw-resize|no-repeat|no-drop|newspaper|ne-resize|n-resize|move|middle|medium|ltr|lr-tb|lowercase|lower-roman|lower-alpha|loose|list-item|line|line-through|line-edge|lighter|left|keep-all|justify|italic|inter-word|inter-ideograph|inside|inset|inline|inline-block|inherit|inactive|ideograph-space|ideograph-parenthesis|ideograph-numeric|ideograph-alpha|horizontal|hidden|help|hand|groove|fixed|ellipsis|e-resize|double|dotted|distribute|distribute-space|distribute-letter|distribute-all-lines|disc|disabled|default|decimal|dashed|crosshair|collapse|col-resize|circle|char|center|capitalize|break-word|break-all|bottom|both|bolder|bold|block|bidi-override|below|baseline|auto|always|all-scroll|absolute|table|table-cell)\\b"
    },{begin:":",end:";",
    contains:[c,n.HEXCOLOR,n.CSS_NUMBER_MODE,a.QUOTE_STRING_MODE,a.APOS_STRING_MODE,n.IMPORTANT]
    },{begin:"@(page|font-face)",keywords:{$pattern:d,keyword:"@page @font-face"}},{
    begin:"@",end:"[{;]",returnBegin:!0,keywords:{$pattern:/[a-z-]+/,
    keyword:"and or not only",attribute:t.join(" ")},contains:[{begin:d,
    className:"keyword"},{begin:/[a-z-]+(?=:)/,className:"attribute"
    },c,a.QUOTE_STRING_MODE,a.APOS_STRING_MODE,n.HEXCOLOR,n.CSS_NUMBER_MODE]}]}}
    })());hljs.registerLanguage("objectivec",(()=>{"use strict";return e=>{
    const n=/[a-zA-Z@][a-zA-Z0-9_]*/,_={$pattern:n,
    keyword:["@interface","@class","@protocol","@implementation"]};return{
    name:"Objective-C",aliases:["mm","objc","obj-c","obj-c++","objective-c++"],
    keywords:{$pattern:n,
    keyword:["int","float","while","char","export","sizeof","typedef","const","struct","for","union","unsigned","long","volatile","static","bool","mutable","if","do","return","goto","void","enum","else","break","extern","asm","case","short","default","double","register","explicit","signed","typename","this","switch","continue","wchar_t","inline","readonly","assign","readwrite","self","@synchronized","id","typeof","nonatomic","super","unichar","IBOutlet","IBAction","strong","weak","copy","in","out","inout","bycopy","byref","oneway","__strong","__weak","__block","__autoreleasing","@private","@protected","@public","@try","@property","@end","@throw","@catch","@finally","@autoreleasepool","@synthesize","@dynamic","@selector","@optional","@required","@encode","@package","@import","@defs","@compatibility_alias","__bridge","__bridge_transfer","__bridge_retained","__bridge_retain","__covariant","__contravariant","__kindof","_Nonnull","_Nullable","_Null_unspecified","__FUNCTION__","__PRETTY_FUNCTION__","__attribute__","getter","setter","retain","unsafe_unretained","nonnull","nullable","null_unspecified","null_resettable","class","instancetype","NS_DESIGNATED_INITIALIZER","NS_UNAVAILABLE","NS_REQUIRES_SUPER","NS_RETURNS_INNER_POINTER","NS_INLINE","NS_AVAILABLE","NS_DEPRECATED","NS_ENUM","NS_OPTIONS","NS_SWIFT_UNAVAILABLE","NS_ASSUME_NONNULL_BEGIN","NS_ASSUME_NONNULL_END","NS_REFINED_FOR_SWIFT","NS_SWIFT_NAME","NS_SWIFT_NOTHROW","NS_DURING","NS_HANDLER","NS_ENDHANDLER","NS_VALUERETURN","NS_VOIDRETURN"],
    literal:["false","true","FALSE","TRUE","nil","YES","NO","NULL"],
    built_in:["BOOL","dispatch_once_t","dispatch_queue_t","dispatch_sync","dispatch_async","dispatch_once"]
    },illegal:"</",contains:[{className:"built_in",
    begin:"\\b(AV|CA|CF|CG|CI|CL|CM|CN|CT|MK|MP|MTK|MTL|NS|SCN|SK|UI|WK|XC)\\w+"
    },e.C_LINE_COMMENT_MODE,e.C_BLOCK_COMMENT_MODE,e.C_NUMBER_MODE,e.QUOTE_STRING_MODE,e.APOS_STRING_MODE,{
    className:"string",variants:[{begin:'@"',end:'"',illegal:"\\n",
    contains:[e.BACKSLASH_ESCAPE]}]},{className:"meta",begin:/#\s*[a-z]+\b/,end:/$/,
    keywords:{
    keyword:"if else elif endif define undef warning error line pragma ifdef ifndef include"
    },contains:[{begin:/\\\n/,relevance:0},e.inherit(e.QUOTE_STRING_MODE,{
    className:"string"}),{className:"string",begin:/<.*?>/,end:/$/,illegal:"\\n"
    },e.C_LINE_COMMENT_MODE,e.C_BLOCK_COMMENT_MODE]},{className:"class",
    begin:"("+_.keyword.join("|")+")\\b",end:/(\{|$)/,excludeEnd:!0,keywords:_,
    contains:[e.UNDERSCORE_TITLE_MODE]},{begin:"\\."+e.UNDERSCORE_IDENT_RE,
    relevance:0}]}}})());hljs.registerLanguage("kotlin",(()=>{"use strict"
    ;var e="\\.([0-9](_*[0-9])*)",n="[0-9a-fA-F](_*[0-9a-fA-F])*",a={
    className:"number",variants:[{
    begin:`(\\b([0-9](_*[0-9])*)((${e})|\\.)?|(${e}))[eE][+-]?([0-9](_*[0-9])*)[fFdD]?\\b`
    },{begin:`\\b([0-9](_*[0-9])*)((${e})[fFdD]?\\b|\\.([fFdD]\\b)?)`},{
    begin:`(${e})[fFdD]?\\b`},{begin:"\\b([0-9](_*[0-9])*)[fFdD]\\b"},{
    begin:`\\b0[xX]((${n})\\.?|(${n})?\\.(${n}))[pP][+-]?([0-9](_*[0-9])*)[fFdD]?\\b`
    },{begin:"\\b(0|[1-9](_*[0-9])*)[lL]?\\b"},{begin:`\\b0[xX](${n})[lL]?\\b`},{
    begin:"\\b0(_*[0-7])*[lL]?\\b"},{begin:"\\b0[bB][01](_*[01])*[lL]?\\b"}],
    relevance:0};return e=>{const n={
    keyword:"abstract as val var vararg get set class object open private protected public noinline crossinline dynamic final enum if else do while for when throw try catch finally import package is in fun override companion reified inline lateinit init interface annotation data sealed internal infix operator out by constructor super tailrec where const inner suspend typealias external expect actual",
    built_in:"Byte Short Char Int Long Boolean Float Double Void Unit Nothing",
    literal:"true false null"},i={className:"symbol",begin:e.UNDERSCORE_IDENT_RE+"@"
    },s={className:"subst",begin:/\$\{/,end:/\}/,contains:[e.C_NUMBER_MODE]},t={
    className:"variable",begin:"\\$"+e.UNDERSCORE_IDENT_RE},r={className:"string",
    variants:[{begin:'"""',end:'"""(?=[^"])',contains:[t,s]},{begin:"'",end:"'",
    illegal:/\n/,contains:[e.BACKSLASH_ESCAPE]},{begin:'"',end:'"',illegal:/\n/,
    contains:[e.BACKSLASH_ESCAPE,t,s]}]};s.contains.push(r);const l={
    className:"meta",
    begin:"@(?:file|property|field|get|set|receiver|param|setparam|delegate)\\s*:(?:\\s*"+e.UNDERSCORE_IDENT_RE+")?"
    },c={className:"meta",begin:"@"+e.UNDERSCORE_IDENT_RE,contains:[{begin:/\(/,
    end:/\)/,contains:[e.inherit(r,{className:"string"})]}]
    },o=a,b=e.COMMENT("/\\*","\\*/",{contains:[e.C_BLOCK_COMMENT_MODE]}),E={
    variants:[{className:"type",begin:e.UNDERSCORE_IDENT_RE},{begin:/\(/,end:/\)/,
    contains:[]}]},d=E;return d.variants[1].contains=[E],E.variants[1].contains=[d],
    {name:"Kotlin",aliases:["kt","kts"],keywords:n,
    contains:[e.COMMENT("/\\*\\*","\\*/",{relevance:0,contains:[{className:"doctag",
    begin:"@[A-Za-z]+"}]}),e.C_LINE_COMMENT_MODE,b,{className:"keyword",
    begin:/\b(break|continue|return|this)\b/,starts:{contains:[{className:"symbol",
    begin:/@\w+/}]}},i,l,c,{className:"function",beginKeywords:"fun",end:"[(]|$",
    returnBegin:!0,excludeEnd:!0,keywords:n,relevance:5,contains:[{
    begin:e.UNDERSCORE_IDENT_RE+"\\s*\\(",returnBegin:!0,relevance:0,
    contains:[e.UNDERSCORE_TITLE_MODE]},{className:"type",begin:/</,end:/>/,
    keywords:"reified",relevance:0},{className:"params",begin:/\(/,end:/\)/,
    endsParent:!0,keywords:n,relevance:0,contains:[{begin:/:/,end:/[=,\/]/,
    endsWithParent:!0,contains:[E,e.C_LINE_COMMENT_MODE,b],relevance:0
    },e.C_LINE_COMMENT_MODE,b,l,c,r,e.C_NUMBER_MODE]},b]},{className:"class",
    beginKeywords:"class interface trait",end:/[:\{(]|$/,excludeEnd:!0,
    illegal:"extends implements",contains:[{
    beginKeywords:"public protected internal private constructor"
    },e.UNDERSCORE_TITLE_MODE,{className:"type",begin:/</,end:/>/,excludeBegin:!0,
    excludeEnd:!0,relevance:0},{className:"type",begin:/[,:]\s*/,end:/[<\(,]|$/,
    excludeBegin:!0,returnEnd:!0},l,c]},r,{className:"meta",begin:"^#!/usr/bin/env",
    end:"$",illegal:"\n"},o]}}})());hljs.registerLanguage("xml",(()=>{"use strict";function e(e){
    return e?"string"==typeof e?e:e.source:null}function n(e){return a("(?=",e,")")}
    function a(...n){return n.map((n=>e(n))).join("")}function s(...n){
    return"("+((e=>{const n=e[e.length-1]
    ;return"object"==typeof n&&n.constructor===Object?(e.splice(e.length-1,1),n):{}
    })(n).capture?"":"?:")+n.map((n=>e(n))).join("|")+")"}return e=>{
    const t=a(/[A-Z_]/,a("(?:",/[A-Z0-9_.-]*:/,")?"),/[A-Z0-9_.-]*/),i={
    className:"symbol",begin:/&[a-z]+;|&#[0-9]+;|&#x[a-f0-9]+;/},c={begin:/\s/,
    contains:[{className:"keyword",begin:/#?[a-z_][a-z1-9_-]+/,illegal:/\n/}]
    },r=e.inherit(c,{begin:/\(/,end:/\)/}),l=e.inherit(e.APOS_STRING_MODE,{
    className:"string"}),g=e.inherit(e.QUOTE_STRING_MODE,{className:"string"}),m={
    endsWithParent:!0,illegal:/</,relevance:0,contains:[{className:"attr",
    begin:/[A-Za-z0-9._:-]+/,relevance:0},{begin:/=\s*/,relevance:0,contains:[{
    className:"string",endsParent:!0,variants:[{begin:/"/,end:/"/,contains:[i]},{
    begin:/'/,end:/'/,contains:[i]},{begin:/[^\s"'=<>`]+/}]}]}]};return{
    name:"HTML, XML",
    aliases:["html","xhtml","rss","atom","xjb","xsd","xsl","plist","wsf","svg"],
    case_insensitive:!0,contains:[{className:"meta",begin:/<![a-z]/,end:/>/,
    relevance:10,contains:[c,g,l,r,{begin:/\[/,end:/\]/,contains:[{className:"meta",
    begin:/<![a-z]/,end:/>/,contains:[c,r,g,l]}]}]},e.COMMENT(/<!--/,/-->/,{
    relevance:10}),{begin:/<!\[CDATA\[/,end:/\]\]>/,relevance:10},i,{
    className:"meta",begin:/<\?xml/,end:/\?>/,relevance:10},{className:"tag",
    begin:/<style(?=\s|>)/,end:/>/,keywords:{name:"style"},contains:[m],starts:{
    end:/<\/style>/,returnEnd:!0,subLanguage:["css","xml"]}},{className:"tag",
    begin:/<script(?=\s|>)/,end:/>/,keywords:{name:"script"},contains:[m],starts:{
    end:/<\/script>/,returnEnd:!0,subLanguage:["javascript","handlebars","xml"]}},{
    className:"tag",begin:/<>|<\/>/},{className:"tag",
    begin:a(/</,n(a(t,s(/\/>/,/>/,/\s/)))),end:/\/?>/,contains:[{className:"name",
    begin:t,relevance:0,starts:m}]},{className:"tag",begin:a(/<\//,n(a(t,/>/))),
    contains:[{className:"name",begin:t,relevance:0},{begin:/>/,relevance:0,
    endsParent:!0}]}]}}})());hljs.registerLanguage("markdown",(()=>{"use strict";function n(...n){
    return n.map((n=>{return(e=n)?"string"==typeof e?e:e.source:null;var e
    })).join("")}return e=>{const a={begin:/<\/?[A-Za-z_]/,end:">",
    subLanguage:"xml",relevance:0},i={variants:[{begin:/\[.+?\]\[.*?\]/,relevance:0
    },{begin:/\[.+?\]\(((data|javascript|mailto):|(?:http|ftp)s?:\/\/).*?\)/,
    relevance:2},{begin:n(/\[.+?\]\(/,/[A-Za-z][A-Za-z0-9+.-]*/,/:\/\/.*?\)/),
    relevance:2},{begin:/\[.+?\]\([./?&#].*?\)/,relevance:1},{
    begin:/\[.+?\]\(.*?\)/,relevance:0}],returnBegin:!0,contains:[{
    className:"string",relevance:0,begin:"\\[",end:"\\]",excludeBegin:!0,
    returnEnd:!0},{className:"link",relevance:0,begin:"\\]\\(",end:"\\)",
    excludeBegin:!0,excludeEnd:!0},{className:"symbol",relevance:0,begin:"\\]\\[",
    end:"\\]",excludeBegin:!0,excludeEnd:!0}]},s={className:"strong",contains:[],
    variants:[{begin:/_{2}/,end:/_{2}/},{begin:/\*{2}/,end:/\*{2}/}]},c={
    className:"emphasis",contains:[],variants:[{begin:/\*(?!\*)/,end:/\*/},{
    begin:/_(?!_)/,end:/_/,relevance:0}]};s.contains.push(c),c.contains.push(s)
    ;let t=[a,i]
    ;return s.contains=s.contains.concat(t),c.contains=c.contains.concat(t),
    t=t.concat(s,c),{name:"Markdown",aliases:["md","mkdown","mkd"],contains:[{
    className:"section",variants:[{begin:"^#{1,6}",end:"$",contains:t},{
    begin:"(?=^.+?\\n[=-]{2,}$)",contains:[{begin:"^[=-]*$"},{begin:"^",end:"\\n",
    contains:t}]}]},a,{className:"bullet",begin:"^[ \t]*([*+-]|(\\d+\\.))(?=\\s+)",
    end:"\\s+",excludeEnd:!0},s,c,{className:"quote",begin:"^>\\s+",contains:t,
    end:"$"},{className:"code",variants:[{begin:"(`{3,})[^`](.|\\n)*?\\1`*[ ]*"},{
    begin:"(~{3,})[^~](.|\\n)*?\\1~*[ ]*"},{begin:"```",end:"```+[ ]*$"},{
    begin:"~~~",end:"~~~+[ ]*$"},{begin:"`.+?`"},{begin:"(?=^( {4}|\\t))",
    contains:[{begin:"^( {4}|\\t)",end:"(\\n)$"}],relevance:0}]},{
    begin:"^[-\\*]{3,}",end:"$"},i,{begin:/^\[[^\n]+\]:/,returnBegin:!0,contains:[{
    className:"symbol",begin:/\[/,end:/\]/,excludeBegin:!0,excludeEnd:!0},{
    className:"link",begin:/:\s*/,end:/$/,excludeBegin:!0}]}]}}})());hljs.registerLanguage("dart",(()=>{"use strict";return e=>{const n={
    className:"subst",variants:[{begin:"\\$[A-Za-z0-9_]+"}]},a={className:"subst",
    variants:[{begin:/\$\{/,end:/\}/}],keywords:"true false null this is new super"
    },t={className:"string",variants:[{begin:"r'''",end:"'''"},{begin:'r"""',
    end:'"""'},{begin:"r'",end:"'",illegal:"\\n"},{begin:'r"',end:'"',illegal:"\\n"
    },{begin:"'''",end:"'''",contains:[e.BACKSLASH_ESCAPE,n,a]},{begin:'"""',
    end:'"""',contains:[e.BACKSLASH_ESCAPE,n,a]},{begin:"'",end:"'",illegal:"\\n",
    contains:[e.BACKSLASH_ESCAPE,n,a]},{begin:'"',end:'"',illegal:"\\n",
    contains:[e.BACKSLASH_ESCAPE,n,a]}]};a.contains=[e.C_NUMBER_MODE,t]
    ;const i=["Comparable","DateTime","Duration","Function","Iterable","Iterator","List","Map","Match","Object","Pattern","RegExp","Set","Stopwatch","String","StringBuffer","StringSink","Symbol","Type","Uri","bool","double","int","num","Element","ElementList"],r=i.map((e=>e+"?"))
    ;return{name:"Dart",keywords:{
    keyword:["abstract","as","assert","async","await","break","case","catch","class","const","continue","covariant","default","deferred","do","dynamic","else","enum","export","extends","extension","external","factory","false","final","finally","for","Function","get","hide","if","implements","import","in","inferface","is","late","library","mixin","new","null","on","operator","part","required","rethrow","return","set","show","static","super","switch","sync","this","throw","true","try","typedef","var","void","while","with","yield"],
    built_in:i.concat(r).concat(["Never","Null","dynamic","print","document","querySelector","querySelectorAll","window"]),
    $pattern:/[A-Za-z][A-Za-z0-9_]*\??/},
    contains:[t,e.COMMENT(/\/\*\*(?!\/)/,/\*\//,{subLanguage:"markdown",relevance:0
    }),e.COMMENT(/\/{3,} ?/,/$/,{contains:[{subLanguage:"markdown",begin:".",
    end:"$",relevance:0}]}),e.C_LINE_COMMENT_MODE,e.C_BLOCK_COMMENT_MODE,{
    className:"class",beginKeywords:"class interface",end:/\{/,excludeEnd:!0,
    contains:[{beginKeywords:"extends implements"},e.UNDERSCORE_TITLE_MODE]
    },e.C_NUMBER_MODE,{className:"meta",begin:"@[A-Za-z]+"},{begin:"=>"}]}}})());hljs.registerLanguage("json",(()=>{"use strict";return e=>({name:"JSON",
    contains:[{className:"attr",begin:/"(\\.|[^\\"\r\n])*"(?=\s*:)/,relevance:1.01
    },{match:/[{}[\],:]/,className:"punctuation",relevance:0},e.QUOTE_STRING_MODE,{
    beginKeywords:"true false null"
    },e.C_NUMBER_MODE,e.C_LINE_COMMENT_MODE,e.C_BLOCK_COMMENT_MODE],illegal:"\\S"})
    })());hljs.registerLanguage("bash",(()=>{"use strict";function e(...e){
    return e.map((e=>{return(s=e)?"string"==typeof s?s:s.source:null;var s
    })).join("")}return s=>{const n={},t={begin:/\$\{/,end:/\}/,contains:["self",{
    begin:/:-/,contains:[n]}]};Object.assign(n,{className:"variable",variants:[{
    begin:e(/\$[\w\d#@][\w\d_]*/,"(?![\\w\\d])(?![$])")},t]});const a={
    className:"subst",begin:/\$\(/,end:/\)/,contains:[s.BACKSLASH_ESCAPE]},i={
    begin:/<<-?\s*(?=\w+)/,starts:{contains:[s.END_SAME_AS_BEGIN({begin:/(\w+)/,
    end:/(\w+)/,className:"string"})]}},c={className:"string",begin:/"/,end:/"/,
    contains:[s.BACKSLASH_ESCAPE,n,a]};a.contains.push(c);const o={begin:/\$\(\(/,
    end:/\)\)/,contains:[{begin:/\d+#[0-9a-f]+/,className:"number"},s.NUMBER_MODE,n]
    },r=s.SHEBANG({binary:"(fish|bash|zsh|sh|csh|ksh|tcsh|dash|scsh)",relevance:10
    }),l={className:"function",begin:/\w[\w\d_]*\s*\(\s*\)\s*\{/,returnBegin:!0,
    contains:[s.inherit(s.TITLE_MODE,{begin:/\w[\w\d_]*/})],relevance:0};return{
    name:"Bash",aliases:["sh"],keywords:{$pattern:/\b[a-z._-]+\b/,
    keyword:["if","then","else","elif","fi","for","while","in","do","done","case","esac","function"],
    literal:["true","false"],
    built_in:"break cd continue eval exec exit export getopts hash pwd readonly return shift test times trap umask unset alias bind builtin caller command declare echo enable help let local logout mapfile printf read readarray source type typeset ulimit unalias set shopt autoload bg bindkey bye cap chdir clone comparguments compcall compctl compdescribe compfiles compgroups compquote comptags comptry compvalues dirs disable disown echotc echoti emulate fc fg float functions getcap getln history integer jobs kill limit log noglob popd print pushd pushln rehash sched setcap setopt stat suspend ttyctl unfunction unhash unlimit unsetopt vared wait whence where which zcompile zformat zftp zle zmodload zparseopts zprof zpty zregexparse zsocket zstyle ztcp"
    },contains:[r,s.SHEBANG(),l,o,s.HASH_COMMENT_MODE,i,c,{className:"",begin:/\\"/
    },{className:"string",begin:/'/,end:/'/},n]}}})());hljs.registerLanguage("csharp",(()=>{"use strict";return e=>{const n={
    keyword:["abstract","as","base","break","case","class","const","continue","do","else","event","explicit","extern","finally","fixed","for","foreach","goto","if","implicit","in","interface","internal","is","lock","namespace","new","operator","out","override","params","private","protected","public","readonly","record","ref","return","sealed","sizeof","stackalloc","static","struct","switch","this","throw","try","typeof","unchecked","unsafe","using","virtual","void","volatile","while"].concat(["add","alias","and","ascending","async","await","by","descending","equals","from","get","global","group","init","into","join","let","nameof","not","notnull","on","or","orderby","partial","remove","select","set","unmanaged","value|0","var","when","where","with","yield"]),
    built_in:["bool","byte","char","decimal","delegate","double","dynamic","enum","float","int","long","nint","nuint","object","sbyte","short","string","ulong","uint","ushort"],
    literal:["default","false","null","true"]},i=e.inherit(e.TITLE_MODE,{
    begin:"[a-zA-Z](\\.?\\w)*"}),a={className:"number",variants:[{
    begin:"\\b(0b[01']+)"},{
    begin:"(-?)\\b([\\d']+(\\.[\\d']*)?|\\.[\\d']+)(u|U|l|L|ul|UL|f|F|b|B)"},{
    begin:"(-?)(\\b0[xX][a-fA-F0-9']+|(\\b[\\d']+(\\.[\\d']*)?|\\.[\\d']+)([eE][-+]?[\\d']+)?)"
    }],relevance:0},s={className:"string",begin:'@"',end:'"',contains:[{begin:'""'}]
    },t=e.inherit(s,{illegal:/\n/}),r={className:"subst",begin:/\{/,end:/\}/,
    keywords:n},l=e.inherit(r,{illegal:/\n/}),c={className:"string",begin:/\$"/,
    end:'"',illegal:/\n/,contains:[{begin:/\{\{/},{begin:/\}\}/
    },e.BACKSLASH_ESCAPE,l]},o={className:"string",begin:/\$@"/,end:'"',contains:[{
    begin:/\{\{/},{begin:/\}\}/},{begin:'""'},r]},d=e.inherit(o,{illegal:/\n/,
    contains:[{begin:/\{\{/},{begin:/\}\}/},{begin:'""'},l]})
    ;r.contains=[o,c,s,e.APOS_STRING_MODE,e.QUOTE_STRING_MODE,a,e.C_BLOCK_COMMENT_MODE],
    l.contains=[d,c,t,e.APOS_STRING_MODE,e.QUOTE_STRING_MODE,a,e.inherit(e.C_BLOCK_COMMENT_MODE,{
    illegal:/\n/})];const g={variants:[o,c,s,e.APOS_STRING_MODE,e.QUOTE_STRING_MODE]
    },E={begin:"<",end:">",contains:[{beginKeywords:"in out"},i]
    },_=e.IDENT_RE+"(<"+e.IDENT_RE+"(\\s*,\\s*"+e.IDENT_RE+")*>)?(\\[\\])?",b={
    begin:"@"+e.IDENT_RE,relevance:0};return{name:"C#",aliases:["cs","c#"],
    keywords:n,illegal:/::/,contains:[e.COMMENT("///","$",{returnBegin:!0,
    contains:[{className:"doctag",variants:[{begin:"///",relevance:0},{
    begin:"\x3c!--|--\x3e"},{begin:"</?",end:">"}]}]
    }),e.C_LINE_COMMENT_MODE,e.C_BLOCK_COMMENT_MODE,{className:"meta",begin:"#",
    end:"$",keywords:{
    keyword:"if else elif endif define undef warning error line region endregion pragma checksum"
    }},g,a,{beginKeywords:"class interface",relevance:0,end:/[{;=]/,
    illegal:/[^\s:,]/,contains:[{beginKeywords:"where class"
    },i,E,e.C_LINE_COMMENT_MODE,e.C_BLOCK_COMMENT_MODE]},{beginKeywords:"namespace",
    relevance:0,end:/[{;=]/,illegal:/[^\s:]/,
    contains:[i,e.C_LINE_COMMENT_MODE,e.C_BLOCK_COMMENT_MODE]},{
    beginKeywords:"record",relevance:0,end:/[{;=]/,illegal:/[^\s:]/,
    contains:[i,E,e.C_LINE_COMMENT_MODE,e.C_BLOCK_COMMENT_MODE]},{className:"meta",
    begin:"^\\s*\\[(?=[\\w])",excludeBegin:!0,end:"\\]",excludeEnd:!0,contains:[{
    className:"string",begin:/"/,end:/"/}]},{
    beginKeywords:"new return throw await else",relevance:0},{className:"function",
    begin:"("+_+"\\s+)+"+e.IDENT_RE+"\\s*(<.+>\\s*)?\\(",returnBegin:!0,
    end:/\s*[{;=]/,excludeEnd:!0,keywords:n,contains:[{
    beginKeywords:"public private protected static internal protected abstract async extern override unsafe virtual new sealed partial",
    relevance:0},{begin:e.IDENT_RE+"\\s*(<.+>\\s*)?\\(",returnBegin:!0,
    contains:[e.TITLE_MODE,E],relevance:0},{className:"params",begin:/\(/,end:/\)/,
    excludeBegin:!0,excludeEnd:!0,keywords:n,relevance:0,
    contains:[g,a,e.C_BLOCK_COMMENT_MODE]
    },e.C_LINE_COMMENT_MODE,e.C_BLOCK_COMMENT_MODE]},b]}}})());hljs.registerLanguage("ruby",(()=>{"use strict";function e(e){
    return n("(?=",e,")")}function n(...e){return e.map((e=>{
    return(n=e)?"string"==typeof n?n:n.source:null;var n})).join("")}return a=>{
    const i="([a-zA-Z_]\\w*[!?=]?|[-+~]@|<<|>>|=~|===?|<=>|[<>]=?|\\*\\*|[-/+%^&*~`|]|\\[\\]=?)",s={
    keyword:"and then defined module in return redo if BEGIN retry end for self when next until do begin unless END rescue else break undef not super class case require yield alias while ensure elsif or include attr_reader attr_writer attr_accessor __FILE__",
    built_in:"proc lambda",literal:"true false nil"},r={className:"doctag",
    begin:"@[A-Za-z]+"},b={begin:"#<",end:">"},c=[a.COMMENT("#","$",{contains:[r]
    }),a.COMMENT("^=begin","^=end",{contains:[r],relevance:10
    }),a.COMMENT("^__END__","\\n$")],t={className:"subst",begin:/#\{/,end:/\}/,
    keywords:s},g={className:"string",contains:[a.BACKSLASH_ESCAPE,t],variants:[{
    begin:/'/,end:/'/},{begin:/"/,end:/"/},{begin:/`/,end:/`/},{begin:/%[qQwWx]?\(/,
    end:/\)/},{begin:/%[qQwWx]?\[/,end:/\]/},{begin:/%[qQwWx]?\{/,end:/\}/},{
    begin:/%[qQwWx]?</,end:/>/},{begin:/%[qQwWx]?\//,end:/\//},{begin:/%[qQwWx]?%/,
    end:/%/},{begin:/%[qQwWx]?-/,end:/-/},{begin:/%[qQwWx]?\|/,end:/\|/},{
    begin:/\B\?(\\\d{1,3})/},{begin:/\B\?(\\x[A-Fa-f0-9]{1,2})/},{
    begin:/\B\?(\\u\{?[A-Fa-f0-9]{1,6}\}?)/},{
    begin:/\B\?(\\M-\\C-|\\M-\\c|\\c\\M-|\\M-|\\C-\\M-)[\x20-\x7e]/},{
    begin:/\B\?\\(c|C-)[\x20-\x7e]/},{begin:/\B\?\\?\S/},{
    begin:n(/<<[-~]?'?/,e(/(\w+)(?=\W)[^\n]*\n(?:[^\n]*\n)*?\s*\1\b/)),
    contains:[a.END_SAME_AS_BEGIN({begin:/(\w+)/,end:/(\w+)/,
    contains:[a.BACKSLASH_ESCAPE,t]})]}]},d="[0-9](_?[0-9])*",l={className:"number",
    relevance:0,variants:[{
    begin:`\\b([1-9](_?[0-9])*|0)(\\.(${d}))?([eE][+-]?(${d})|r)?i?\\b`},{
    begin:"\\b0[dD][0-9](_?[0-9])*r?i?\\b"},{begin:"\\b0[bB][0-1](_?[0-1])*r?i?\\b"
    },{begin:"\\b0[oO][0-7](_?[0-7])*r?i?\\b"},{
    begin:"\\b0[xX][0-9a-fA-F](_?[0-9a-fA-F])*r?i?\\b"},{
    begin:"\\b0(_?[0-7])+r?i?\\b"}]},o={className:"params",begin:"\\(",end:"\\)",
    endsParent:!0,keywords:s},_=[g,{className:"class",beginKeywords:"class module",
    end:"$|;",illegal:/=/,contains:[a.inherit(a.TITLE_MODE,{
    begin:"[A-Za-z_]\\w*(::\\w+)*(\\?|!)?"}),{begin:"<\\s*",contains:[{
    begin:"("+a.IDENT_RE+"::)?"+a.IDENT_RE,relevance:0}]}].concat(c)},{
    className:"function",begin:n(/def\s+/,e(i+"\\s*(\\(|;|$)")),relevance:0,
    keywords:"def",end:"$|;",contains:[a.inherit(a.TITLE_MODE,{begin:i
    }),o].concat(c)},{begin:a.IDENT_RE+"::"},{className:"symbol",
    begin:a.UNDERSCORE_IDENT_RE+"(!|\\?)?:",relevance:0},{className:"symbol",
    begin:":(?!\\s)",contains:[g,{begin:i}],relevance:0},l,{className:"variable",
    begin:"(\\$\\W)|((\\$|@@?)(\\w+))(?=[^@$?])(?![A-Za-z])(?![@$?'])"},{
    className:"params",begin:/\|/,end:/\|/,relevance:0,keywords:s},{
    begin:"("+a.RE_STARTERS_RE+"|unless)\\s*",keywords:"unless",contains:[{
    className:"regexp",contains:[a.BACKSLASH_ESCAPE,t],illegal:/\n/,variants:[{
    begin:"/",end:"/[a-z]*"},{begin:/%r\{/,end:/\}[a-z]*/},{begin:"%r\\(",
    end:"\\)[a-z]*"},{begin:"%r!",end:"![a-z]*"},{begin:"%r\\[",end:"\\][a-z]*"}]
    }].concat(b,c),relevance:0}].concat(b,c);t.contains=_,o.contains=_;const E=[{
    begin:/^\s*=>/,starts:{end:"$",contains:_}},{className:"meta",
    begin:"^([>?]>|[\\w#]+\\(\\w+\\):\\d+:\\d+>|(\\w+-)?\\d+\\.\\d+\\.\\d+(p\\d+)?[^\\d][^>]+>)(?=[ ])",
    starts:{end:"$",contains:_}}];return c.unshift(b),{name:"Ruby",
    aliases:["rb","gemspec","podspec","thor","irb"],keywords:s,illegal:/\/\*/,
    contains:[a.SHEBANG({binary:"ruby"})].concat(E).concat(c).concat(_)}}})());hljs.registerLanguage("yaml",(()=>{"use strict";return e=>{
    const n="true false yes no null",a="[\\w#;/?:@&=+$,.~*'()[\\]]+",s={
    className:"string",relevance:0,variants:[{begin:/'/,end:/'/},{begin:/"/,end:/"/
    },{begin:/\S+/}],contains:[e.BACKSLASH_ESCAPE,{className:"template-variable",
    variants:[{begin:/\{\{/,end:/\}\}/},{begin:/%\{/,end:/\}/}]}]},i=e.inherit(s,{
    variants:[{begin:/'/,end:/'/},{begin:/"/,end:/"/},{begin:/[^\s,{}[\]]+/}]}),l={
    end:",",endsWithParent:!0,excludeEnd:!0,keywords:n,relevance:0},t={begin:/\{/,
    end:/\}/,contains:[l],illegal:"\\n",relevance:0},g={begin:"\\[",end:"\\]",
    contains:[l],illegal:"\\n",relevance:0},b=[{className:"attr",variants:[{
    begin:"\\w[\\w :\\/.-]*:(?=[ \t]|$)"},{begin:'"\\w[\\w :\\/.-]*":(?=[ \t]|$)'},{
    begin:"'\\w[\\w :\\/.-]*':(?=[ \t]|$)"}]},{className:"meta",begin:"^---\\s*$",
    relevance:10},{className:"string",
    begin:"[\\|>]([1-9]?[+-])?[ ]*\\n( +)[^ ][^\\n]*\\n(\\2[^\\n]+\\n?)*"},{
    begin:"<%[%=-]?",end:"[%-]?%>",subLanguage:"ruby",excludeBegin:!0,excludeEnd:!0,
    relevance:0},{className:"type",begin:"!\\w+!"+a},{className:"type",
    begin:"!<"+a+">"},{className:"type",begin:"!"+a},{className:"type",begin:"!!"+a
    },{className:"meta",begin:"&"+e.UNDERSCORE_IDENT_RE+"$"},{className:"meta",
    begin:"\\*"+e.UNDERSCORE_IDENT_RE+"$"},{className:"bullet",begin:"-(?=[ ]|$)",
    relevance:0},e.HASH_COMMENT_MODE,{beginKeywords:n,keywords:{literal:n}},{
    className:"number",
    begin:"\\b[0-9]{4}(-[0-9][0-9]){0,2}([Tt \\t][0-9][0-9]?(:[0-9][0-9]){2})?(\\.[0-9]*)?([ \\t])*(Z|[-+][0-9][0-9]?(:[0-9][0-9])?)?\\b"
    },{className:"number",begin:e.C_NUMBER_RE+"\\b",relevance:0},t,g,s],c=[...b]
    ;return c.pop(),c.push(i),l.contains=c,{name:"YAML",case_insensitive:!0,
    aliases:["yml"],contains:b}}})());hljs.registerLanguage("css",(()=>{"use strict"
    ;const e=["a","abbr","address","article","aside","audio","b","blockquote","body","button","canvas","caption","cite","code","dd","del","details","dfn","div","dl","dt","em","fieldset","figcaption","figure","footer","form","h1","h2","h3","h4","h5","h6","header","hgroup","html","i","iframe","img","input","ins","kbd","label","legend","li","main","mark","menu","nav","object","ol","p","q","quote","samp","section","span","strong","summary","sup","table","tbody","td","textarea","tfoot","th","thead","time","tr","ul","var","video"],t=["any-hover","any-pointer","aspect-ratio","color","color-gamut","color-index","device-aspect-ratio","device-height","device-width","display-mode","forced-colors","grid","height","hover","inverted-colors","monochrome","orientation","overflow-block","overflow-inline","pointer","prefers-color-scheme","prefers-contrast","prefers-reduced-motion","prefers-reduced-transparency","resolution","scan","scripting","update","width","min-width","max-width","min-height","max-height"],i=["active","any-link","blank","checked","current","default","defined","dir","disabled","drop","empty","enabled","first","first-child","first-of-type","fullscreen","future","focus","focus-visible","focus-within","has","host","host-context","hover","indeterminate","in-range","invalid","is","lang","last-child","last-of-type","left","link","local-link","not","nth-child","nth-col","nth-last-child","nth-last-col","nth-last-of-type","nth-of-type","only-child","only-of-type","optional","out-of-range","past","placeholder-shown","read-only","read-write","required","right","root","scope","target","target-within","user-invalid","valid","visited","where"],o=["after","backdrop","before","cue","cue-region","first-letter","first-line","grammar-error","marker","part","placeholder","selection","slotted","spelling-error"],r=["align-content","align-items","align-self","animation","animation-delay","animation-direction","animation-duration","animation-fill-mode","animation-iteration-count","animation-name","animation-play-state","animation-timing-function","auto","backface-visibility","background","background-attachment","background-clip","background-color","background-image","background-origin","background-position","background-repeat","background-size","border","border-bottom","border-bottom-color","border-bottom-left-radius","border-bottom-right-radius","border-bottom-style","border-bottom-width","border-collapse","border-color","border-image","border-image-outset","border-image-repeat","border-image-slice","border-image-source","border-image-width","border-left","border-left-color","border-left-style","border-left-width","border-radius","border-right","border-right-color","border-right-style","border-right-width","border-spacing","border-style","border-top","border-top-color","border-top-left-radius","border-top-right-radius","border-top-style","border-top-width","border-width","bottom","box-decoration-break","box-shadow","box-sizing","break-after","break-before","break-inside","caption-side","clear","clip","clip-path","color","column-count","column-fill","column-gap","column-rule","column-rule-color","column-rule-style","column-rule-width","column-span","column-width","columns","content","counter-increment","counter-reset","cursor","direction","display","empty-cells","filter","flex","flex-basis","flex-direction","flex-flow","flex-grow","flex-shrink","flex-wrap","float","font","font-display","font-family","font-feature-settings","font-kerning","font-language-override","font-size","font-size-adjust","font-smoothing","font-stretch","font-style","font-variant","font-variant-ligatures","font-variation-settings","font-weight","height","hyphens","icon","image-orientation","image-rendering","image-resolution","ime-mode","inherit","initial","justify-content","left","letter-spacing","line-height","list-style","list-style-image","list-style-position","list-style-type","margin","margin-bottom","margin-left","margin-right","margin-top","marks","mask","max-height","max-width","min-height","min-width","nav-down","nav-index","nav-left","nav-right","nav-up","none","normal","object-fit","object-position","opacity","order","orphans","outline","outline-color","outline-offset","outline-style","outline-width","overflow","overflow-wrap","overflow-x","overflow-y","padding","padding-bottom","padding-left","padding-right","padding-top","page-break-after","page-break-before","page-break-inside","perspective","perspective-origin","pointer-events","position","quotes","resize","right","src","tab-size","table-layout","text-align","text-align-last","text-decoration","text-decoration-color","text-decoration-line","text-decoration-style","text-indent","text-overflow","text-rendering","text-shadow","text-transform","text-underline-position","top","transform","transform-origin","transform-style","transition","transition-delay","transition-duration","transition-property","transition-timing-function","unicode-bidi","vertical-align","visibility","white-space","widows","width","word-break","word-spacing","word-wrap","z-index"].reverse()
    ;return n=>{const a=(e=>({IMPORTANT:{scope:"meta",begin:"!important"},HEXCOLOR:{
    scope:"number",begin:"#([a-fA-F0-9]{6}|[a-fA-F0-9]{3})"},
    ATTRIBUTE_SELECTOR_MODE:{scope:"selector-attr",begin:/\[/,end:/\]/,illegal:"$",
    contains:[e.APOS_STRING_MODE,e.QUOTE_STRING_MODE]},CSS_NUMBER_MODE:{
    scope:"number",
    begin:e.NUMBER_RE+"(%|em|ex|ch|rem|vw|vh|vmin|vmax|cm|mm|in|pt|pc|px|deg|grad|rad|turn|s|ms|Hz|kHz|dpi|dpcm|dppx)?",
    relevance:0}}))(n),l=[n.APOS_STRING_MODE,n.QUOTE_STRING_MODE];return{name:"CSS",
    case_insensitive:!0,illegal:/[=|'\$]/,keywords:{keyframePosition:"from to"},
    classNameAliases:{keyframePosition:"selector-tag"},
    contains:[n.C_BLOCK_COMMENT_MODE,{begin:/-(webkit|moz|ms|o)-(?=[a-z])/
    },a.CSS_NUMBER_MODE,{className:"selector-id",begin:/#[A-Za-z0-9_-]+/,relevance:0
    },{className:"selector-class",begin:"\\.[a-zA-Z-][a-zA-Z0-9_-]*",relevance:0
    },a.ATTRIBUTE_SELECTOR_MODE,{className:"selector-pseudo",variants:[{
    begin:":("+i.join("|")+")"},{begin:"::("+o.join("|")+")"}]},{
    className:"attribute",begin:"\\b("+r.join("|")+")\\b"},{begin:":",end:"[;}]",
    contains:[a.HEXCOLOR,a.IMPORTANT,a.CSS_NUMBER_MODE,...l,{
    begin:/(url|data-uri)\(/,end:/\)/,relevance:0,keywords:{built_in:"url data-uri"
    },contains:[{className:"string",begin:/[^)]/,endsWithParent:!0,excludeEnd:!0}]
    },{className:"built_in",begin:/[\w-]+(?=\()/}]},{
    begin:(s=/@/,((...e)=>e.map((e=>(e=>e?"string"==typeof e?e:e.source:null)(e))).join(""))("(?=",s,")")),
    end:"[{;]",relevance:0,illegal:/:/,contains:[{className:"keyword",
    begin:/@-?\w[\w]*(-\w+)*/},{begin:/\s/,endsWithParent:!0,excludeEnd:!0,
    relevance:0,keywords:{$pattern:/[a-z-]+/,keyword:"and or not only",
    attribute:t.join(" ")},contains:[{begin:/[a-z-]+(?=:)/,className:"attribute"
    },...l,a.CSS_NUMBER_MODE]}]},{className:"selector-tag",
    begin:"\\b("+e.join("|")+")\\b"}]};var s}})());hljs.registerLanguage("c",(()=>{"use strict";function e(e){
    return((...e)=>e.map((e=>(e=>e?"string"==typeof e?e:e.source:null)(e))).join(""))("(?:",e,")?")
    }return n=>{const t=n.COMMENT("//","$",{contains:[{begin:/\\\n/}]
    }),s="[a-zA-Z_]\\w*::",r="(decltype\\(auto\\)|"+e(s)+"[a-zA-Z_]\\w*"+e("<[^<>]+>")+")",a={
    className:"type",variants:[{begin:"\\b[a-z\\d_]*_t\\b"},{
    match:/\batomic_[a-z]{3,6}\b/}]},i={className:"string",variants:[{
    begin:'(u8?|U|L)?"',end:'"',illegal:"\\n",contains:[n.BACKSLASH_ESCAPE]},{
    begin:"(u8?|U|L)?'(\\\\(x[0-9A-Fa-f]{2}|u[0-9A-Fa-f]{4,8}|[0-7]{3}|\\S)|.)",
    end:"'",illegal:"."},n.END_SAME_AS_BEGIN({
    begin:/(?:u8?|U|L)?R"([^()\\ ]{0,16})\(/,end:/\)([^()\\ ]{0,16})"/})]},l={
    className:"number",variants:[{begin:"\\b(0b[01']+)"},{
    begin:"(-?)\\b([\\d']+(\\.[\\d']*)?|\\.[\\d']+)((ll|LL|l|L)(u|U)?|(u|U)(ll|LL|l|L)?|f|F|b|B)"
    },{
    begin:"(-?)(\\b0[xX][a-fA-F0-9']+|(\\b[\\d']+(\\.[\\d']*)?|\\.[\\d']+)([eE][-+]?[\\d']+)?)"
    }],relevance:0},c={className:"meta",begin:/#\s*[a-z]+\b/,end:/$/,keywords:{
    keyword:"if else elif endif define undef warning error line pragma _Pragma ifdef ifndef include"
    },contains:[{begin:/\\\n/,relevance:0},n.inherit(i,{className:"string"}),{
    className:"string",begin:/<.*?>/},t,n.C_BLOCK_COMMENT_MODE]},o={
    className:"title",begin:e(s)+n.IDENT_RE,relevance:0
    },d=e(s)+n.IDENT_RE+"\\s*\\(",u={
    keyword:["asm","auto","break","case","const","continue","default","do","else","enum","extern","for","fortran","goto","if","inline","register","restrict","return","sizeof","static","struct","switch","typedef","union","volatile","while","_Alignas","_Alignof","_Atomic","_Generic","_Noreturn","_Static_assert","_Thread_local","alignas","alignof","noreturn","static_assert","thread_local","_Pragma"],
    type:["float","double","signed","unsigned","int","short","long","char","void","_Bool","_Complex","_Imaginary","_Decimal32","_Decimal64","_Decimal128","complex","bool","imaginary"],
    literal:"true false NULL",
    built_in:"std string wstring cin cout cerr clog stdin stdout stderr stringstream istringstream ostringstream auto_ptr deque list queue stack vector map set pair bitset multiset multimap unordered_set unordered_map unordered_multiset unordered_multimap priority_queue make_pair array shared_ptr abort terminate abs acos asin atan2 atan calloc ceil cosh cos exit exp fabs floor fmod fprintf fputs free frexp fscanf future isalnum isalpha iscntrl isdigit isgraph islower isprint ispunct isspace isupper isxdigit tolower toupper labs ldexp log10 log malloc realloc memchr memcmp memcpy memset modf pow printf putchar puts scanf sinh sin snprintf sprintf sqrt sscanf strcat strchr strcmp strcpy strcspn strlen strncat strncmp strncpy strpbrk strrchr strspn strstr tanh tan vfprintf vprintf vsprintf endl initializer_list unique_ptr"
    },g=[c,a,t,n.C_BLOCK_COMMENT_MODE,l,i],m={variants:[{begin:/=/,end:/;/},{
    begin:/\(/,end:/\)/},{beginKeywords:"new throw return else",end:/;/}],
    keywords:u,contains:g.concat([{begin:/\(/,end:/\)/,keywords:u,
    contains:g.concat(["self"]),relevance:0}]),relevance:0},_={
    begin:"("+r+"[\\*&\\s]+)+"+d,returnBegin:!0,end:/[{;=]/,excludeEnd:!0,
    keywords:u,illegal:/[^\w\s\*&:<>.]/,contains:[{begin:"decltype\\(auto\\)",
    keywords:u,relevance:0},{begin:d,returnBegin:!0,contains:[n.inherit(o,{
    className:"title.function"})],relevance:0},{relevance:0,match:/,/},{
    className:"params",begin:/\(/,end:/\)/,keywords:u,relevance:0,
    contains:[t,n.C_BLOCK_COMMENT_MODE,i,l,a,{begin:/\(/,end:/\)/,keywords:u,
    relevance:0,contains:["self",t,n.C_BLOCK_COMMENT_MODE,i,l,a]}]
    },a,t,n.C_BLOCK_COMMENT_MODE,c]};return{name:"C",aliases:["h"],keywords:u,
    disableAutodetect:!0,illegal:"</",contains:[].concat(m,_,g,[c,{
    begin:n.IDENT_RE+"::",keywords:u},{className:"class",
    beginKeywords:"enum class struct union",end:/[{;:<>=]/,contains:[{
    beginKeywords:"final class struct"},n.TITLE_MODE]}]),exports:{preprocessor:c,
    strings:i,keywords:u}}}})());hljs.registerLanguage("cpp",(()=>{"use strict";function e(e){
    return t("(?:",e,")?")}function t(...e){return e.map((e=>{
    return(t=e)?"string"==typeof t?t:t.source:null;var t})).join("")}return n=>{
    const a=n.COMMENT("//","$",{contains:[{begin:/\\\n/}]
    }),r="[a-zA-Z_]\\w*::",i="(?!struct)(decltype\\(auto\\)|"+e(r)+"[a-zA-Z_]\\w*"+e("<[^<>]+>")+")",s={
    className:"type",begin:"\\b[a-z\\d_]*_t\\b"},c={className:"string",variants:[{
    begin:'(u8?|U|L)?"',end:'"',illegal:"\\n",contains:[n.BACKSLASH_ESCAPE]},{
    begin:"(u8?|U|L)?'(\\\\(x[0-9A-Fa-f]{2}|u[0-9A-Fa-f]{4,8}|[0-7]{3}|\\S)|.)",
    end:"'",illegal:"."},n.END_SAME_AS_BEGIN({
    begin:/(?:u8?|U|L)?R"([^()\\ ]{0,16})\(/,end:/\)([^()\\ ]{0,16})"/})]},o={
    className:"number",variants:[{begin:"\\b(0b[01']+)"},{
    begin:"(-?)\\b([\\d']+(\\.[\\d']*)?|\\.[\\d']+)((ll|LL|l|L)(u|U)?|(u|U)(ll|LL|l|L)?|f|F|b|B)"
    },{
    begin:"(-?)(\\b0[xX][a-fA-F0-9']+|(\\b[\\d']+(\\.[\\d']*)?|\\.[\\d']+)([eE][-+]?[\\d']+)?)"
    }],relevance:0},l={className:"meta",begin:/#\s*[a-z]+\b/,end:/$/,keywords:{
    keyword:"if else elif endif define undef warning error line pragma _Pragma ifdef ifndef include"
    },contains:[{begin:/\\\n/,relevance:0},n.inherit(c,{className:"string"}),{
    className:"string",begin:/<.*?>/},a,n.C_BLOCK_COMMENT_MODE]},u={
    className:"title",begin:e(r)+n.IDENT_RE,relevance:0
    },d=e(r)+n.IDENT_RE+"\\s*\\(",p={
    type:["bool","char","char16_t","char32_t","char8_t","double","float","int","long","short","void","wchar_t"],
    keyword:["alignas","alignof","and","and_eq","asm","atomic_cancel","atomic_commit","atomic_noexcept","auto","bitand","bitor","break","case","catch","class","co_await","co_return","co_yield","compl","concept","const","const_cast|10","consteval","constexpr","constinit","continue","decltype","default","delete","do","dynamic_cast|10","else","enum","explicit","export","extern","false","final","for","friend","goto","if","import","inline","module","mutable","namespace","new","noexcept","not","not_eq","nullptr","operator","or","or_eq","override","private","protected","public","reflexpr","register","reinterpret_cast|10","requires","return","signed","sizeof","static","static_assert","static_cast|10","struct","switch","synchronized","template","this","thread_local","throw","transaction_safe","transaction_safe_dynamic","true","try","typedef","typeid","typename","union","unsigned","using","virtual","volatile","while","xor","xor_eq,"],
    literal:["NULL","false","nullopt","nullptr","true"],built_in:["_Pragma"],
    _type_hints:["any","auto_ptr","barrier","binary_semaphore","bitset","complex","condition_variable","condition_variable_any","counting_semaphore","deque","false_type","future","imaginary","initializer_list","istringstream","jthread","latch","lock_guard","multimap","multiset","mutex","optional","ostringstream","packaged_task","pair","promise","priority_queue","queue","recursive_mutex","recursive_timed_mutex","scoped_lock","set","shared_future","shared_lock","shared_mutex","shared_timed_mutex","shared_ptr","stack","string_view","stringstream","timed_mutex","thread","true_type","tuple","unique_lock","unique_ptr","unordered_map","unordered_multimap","unordered_multiset","unordered_set","variant","vector","weak_ptr","wstring","wstring_view"]
    },_={className:"function.dispatch",relevance:0,keywords:{
    _hint:["abort","abs","acos","apply","as_const","asin","atan","atan2","calloc","ceil","cerr","cin","clog","cos","cosh","cout","declval","endl","exchange","exit","exp","fabs","floor","fmod","forward","fprintf","fputs","free","frexp","fscanf","future","invoke","isalnum","isalpha","iscntrl","isdigit","isgraph","islower","isprint","ispunct","isspace","isupper","isxdigit","labs","launder","ldexp","log","log10","make_pair","make_shared","make_shared_for_overwrite","make_tuple","make_unique","malloc","memchr","memcmp","memcpy","memset","modf","move","pow","printf","putchar","puts","realloc","scanf","sin","sinh","snprintf","sprintf","sqrt","sscanf","std","stderr","stdin","stdout","strcat","strchr","strcmp","strcpy","strcspn","strlen","strncat","strncmp","strncpy","strpbrk","strrchr","strspn","strstr","swap","tan","tanh","terminate","to_underlying","tolower","toupper","vfprintf","visit","vprintf","vsprintf"]
    },
    begin:t(/\b/,/(?!decltype)/,/(?!if)/,/(?!for)/,/(?!while)/,n.IDENT_RE,(m=/(<[^<>]+>|)\s*\(/,
    t("(?=",m,")")))};var m;const g=[_,l,s,a,n.C_BLOCK_COMMENT_MODE,o,c],f={
    variants:[{begin:/=/,end:/;/},{begin:/\(/,end:/\)/},{
    beginKeywords:"new throw return else",end:/;/}],keywords:p,contains:g.concat([{
    begin:/\(/,end:/\)/,keywords:p,contains:g.concat(["self"]),relevance:0}]),
    relevance:0},b={className:"function",begin:"("+i+"[\\*&\\s]+)+"+d,
    returnBegin:!0,end:/[{;=]/,excludeEnd:!0,keywords:p,illegal:/[^\w\s\*&:<>.]/,
    contains:[{begin:"decltype\\(auto\\)",keywords:p,relevance:0},{begin:d,
    returnBegin:!0,contains:[u],relevance:0},{begin:/::/,relevance:0},{begin:/:/,
    endsWithParent:!0,contains:[c,o]},{relevance:0,match:/,/},{className:"params",
    begin:/\(/,end:/\)/,keywords:p,relevance:0,
    contains:[a,n.C_BLOCK_COMMENT_MODE,c,o,s,{begin:/\(/,end:/\)/,keywords:p,
    relevance:0,contains:["self",a,n.C_BLOCK_COMMENT_MODE,c,o,s]}]
    },s,a,n.C_BLOCK_COMMENT_MODE,l]};return{name:"C++",
    aliases:["cc","c++","h++","hpp","hh","hxx","cxx"],keywords:p,illegal:"</",
    classNameAliases:{"function.dispatch":"built_in"},
    contains:[].concat(f,b,_,g,[l,{
    begin:"\\b(deque|list|queue|priority_queue|pair|stack|vector|map|set|bitset|multiset|multimap|unordered_map|unordered_set|unordered_multiset|unordered_multimap|array|tuple|optional|variant|function)\\s*<",
    end:">",keywords:p,contains:["self",s]},{begin:n.IDENT_RE+"::",keywords:p},{
    match:[/\b(?:enum(?:\s+(?:class|struct))?|class|struct|union)/,/\s+/,/\w+/],
    className:{1:"keyword",3:"title.class"}}])}}})());hljs.registerLanguage("plaintext",(()=>{"use strict";return t=>({
    name:"Plain text",aliases:["text","txt"],disableAutodetect:!0})})());hljs.registerLanguage("shell",(()=>{"use strict";return s=>({
    name:"Shell Session",aliases:["console","shellsession"],contains:[{
    className:"meta",begin:/^\s{0,3}[/~\w\d[\]()@-]*[>%$#][ ]?/,starts:{
    end:/[^\\](?=\s*$)/,subLanguage:"bash"}}]})})());hljs.registerLanguage("gradle",(()=>{"use strict";return e=>({name:"Gradle",
    case_insensitive:!0,
    keywords:["task","project","allprojects","subprojects","artifacts","buildscript","configurations","dependencies","repositories","sourceSets","description","delete","from","into","include","exclude","source","classpath","destinationDir","includes","options","sourceCompatibility","targetCompatibility","group","flatDir","doLast","doFirst","flatten","todir","fromdir","ant","def","abstract","break","case","catch","continue","default","do","else","extends","final","finally","for","if","implements","instanceof","native","new","private","protected","public","return","static","switch","synchronized","throw","throws","transient","try","volatile","while","strictfp","package","import","false","null","super","this","true","antlrtask","checkstyle","codenarc","copy","boolean","byte","char","class","double","float","int","interface","long","short","void","compile","runTime","file","fileTree","abs","any","append","asList","asWritable","call","collect","compareTo","count","div","dump","each","eachByte","eachFile","eachLine","every","find","findAll","flatten","getAt","getErr","getIn","getOut","getText","grep","immutable","inject","inspect","intersect","invokeMethods","isCase","join","leftShift","minus","multiply","newInputStream","newOutputStream","newPrintWriter","newReader","newWriter","next","plus","pop","power","previous","print","println","push","putAt","read","readBytes","readLines","reverse","reverseEach","round","size","sort","splitEachLine","step","subMap","times","toInteger","toList","tokenize","upto","waitForOrKill","withPrintWriter","withReader","withStream","withWriter","withWriterAppend","write","writeLine"],
    contains:[e.C_LINE_COMMENT_MODE,e.C_BLOCK_COMMENT_MODE,e.APOS_STRING_MODE,e.QUOTE_STRING_MODE,e.NUMBER_MODE,e.REGEXP_MODE]
    })})());hljs.registerLanguage("java",(()=>{"use strict"
    ;var e="\\.([0-9](_*[0-9])*)",a="[0-9a-fA-F](_*[0-9a-fA-F])*",n={
    className:"number",variants:[{
    begin:`(\\b([0-9](_*[0-9])*)((${e})|\\.)?|(${e}))[eE][+-]?([0-9](_*[0-9])*)[fFdD]?\\b`
    },{begin:`\\b([0-9](_*[0-9])*)((${e})[fFdD]?\\b|\\.([fFdD]\\b)?)`},{
    begin:`(${e})[fFdD]?\\b`},{begin:"\\b([0-9](_*[0-9])*)[fFdD]\\b"},{
    begin:`\\b0[xX]((${a})\\.?|(${a})?\\.(${a}))[pP][+-]?([0-9](_*[0-9])*)[fFdD]?\\b`
    },{begin:"\\b(0|[1-9](_*[0-9])*)[lL]?\\b"},{begin:`\\b0[xX](${a})[lL]?\\b`},{
    begin:"\\b0(_*[0-7])*[lL]?\\b"},{begin:"\\b0[bB][01](_*[01])*[lL]?\\b"}],
    relevance:0};function s(e,a,n){return-1===n?"":e.replace(a,(t=>s(e,a,n-1)))}
    return e=>{
    const a="[\xc0-\u02b8a-zA-Z_$][\xc0-\u02b8a-zA-Z_$0-9]*",t=a+s("(?:<"+a+"~~~(?:\\s*,\\s*"+a+"~~~)*>)?",/~~~/g,2),i={
    keyword:["synchronized","abstract","private","var","static","if","const ","for","while","strictfp","finally","protected","import","native","final","void","enum","else","break","transient","catch","instanceof","volatile","case","assert","package","default","public","try","switch","continue","throws","protected","public","private","module","requires","exports","do"],
    literal:["false","true","null"],
    type:["char","boolean","long","float","int","byte","short","double"],
    built_in:["super","this"]},r={className:"meta",begin:"@"+a,contains:[{
    begin:/\(/,end:/\)/,contains:["self"]}]},l={className:"params",begin:/\(/,
    end:/\)/,keywords:i,relevance:0,contains:[e.C_BLOCK_COMMENT_MODE],endsParent:!0}
    ;return{name:"Java",aliases:["jsp"],keywords:i,illegal:/<\/|#/,
    contains:[e.COMMENT("/\\*\\*","\\*/",{relevance:0,contains:[{begin:/\w+@/,
    relevance:0},{className:"doctag",begin:"@[A-Za-z]+"}]}),{
    begin:/import java\.[a-z]+\./,keywords:"import",relevance:2
    },e.C_LINE_COMMENT_MODE,e.C_BLOCK_COMMENT_MODE,e.APOS_STRING_MODE,e.QUOTE_STRING_MODE,{
    match:[/\b(?:class|interface|enum|extends|implements|new)/,/\s+/,a],className:{
    1:"keyword",3:"title.class"}},{begin:[a,/\s+/,a,/\s+/,/=/],className:{1:"type",
    3:"variable",5:"operator"}},{begin:[/record/,/\s+/,a],className:{1:"keyword",
    3:"title.class"},contains:[l,e.C_LINE_COMMENT_MODE,e.C_BLOCK_COMMENT_MODE]},{
    beginKeywords:"new throw return else",relevance:0},{
    begin:["(?:"+t+"\\s+)",e.UNDERSCORE_IDENT_RE,/\s*(?=\()/],className:{
    2:"title.function"},keywords:i,contains:[{className:"params",begin:/\(/,
    end:/\)/,keywords:i,relevance:0,
    contains:[r,e.APOS_STRING_MODE,e.QUOTE_STRING_MODE,n,e.C_BLOCK_COMMENT_MODE]
    },e.C_LINE_COMMENT_MODE,e.C_BLOCK_COMMENT_MODE]},n,r]}}})());hljs.registerLanguage("javascript",(()=>{"use strict"
    ;const e="[A-Za-z$_][0-9A-Za-z$_]*",n=["as","in","of","if","for","while","finally","var","new","function","do","return","void","else","break","catch","instanceof","with","throw","case","default","try","switch","continue","typeof","delete","let","yield","const","class","debugger","async","await","static","import","from","export","extends"],a=["true","false","null","undefined","NaN","Infinity"],t=["Intl","DataView","Number","Math","Date","String","RegExp","Object","Function","Boolean","Error","Symbol","Set","Map","WeakSet","WeakMap","Proxy","Reflect","JSON","Promise","Float64Array","Int16Array","Int32Array","Int8Array","Uint16Array","Uint32Array","Float32Array","Array","Uint8Array","Uint8ClampedArray","ArrayBuffer","BigInt64Array","BigUint64Array","BigInt"],s=["EvalError","InternalError","RangeError","ReferenceError","SyntaxError","TypeError","URIError"],r=["setInterval","setTimeout","clearInterval","clearTimeout","require","exports","eval","isFinite","isNaN","parseFloat","parseInt","decodeURI","decodeURIComponent","encodeURI","encodeURIComponent","escape","unescape"],i=["arguments","this","super","console","window","document","localStorage","module","global"],c=[].concat(r,t,s)
    ;function o(e){return l("(?=",e,")")}function l(...e){return e.map((e=>{
    return(n=e)?"string"==typeof n?n:n.source:null;var n})).join("")}return b=>{
    const g=e,d={begin:/<[A-Za-z0-9\\._:-]+/,end:/\/[A-Za-z0-9\\._:-]+>|\/>/,
    isTrulyOpeningTag:(e,n)=>{const a=e[0].length+e.index,t=e.input[a]
    ;"<"!==t?">"===t&&(((e,{after:n})=>{const a="</"+e[0].slice(1)
    ;return-1!==e.input.indexOf(a,n)})(e,{after:a
    })||n.ignoreMatch()):n.ignoreMatch()}},u={$pattern:e,keyword:n,literal:a,
    built_in:c,"variable.language":i
    },m="\\.([0-9](_?[0-9])*)",E="0|[1-9](_?[0-9])*|0[0-7]*[89][0-9]*",y={
    className:"number",variants:[{
    begin:`(\\b(${E})((${m})|\\.)?|(${m}))[eE][+-]?([0-9](_?[0-9])*)\\b`},{
    begin:`\\b(${E})\\b((${m})\\b|\\.)?|(${m})\\b`},{
    begin:"\\b(0|[1-9](_?[0-9])*)n\\b"},{
    begin:"\\b0[xX][0-9a-fA-F](_?[0-9a-fA-F])*n?\\b"},{
    begin:"\\b0[bB][0-1](_?[0-1])*n?\\b"},{begin:"\\b0[oO][0-7](_?[0-7])*n?\\b"},{
    begin:"\\b0[0-7]+n?\\b"}],relevance:0},_={className:"subst",begin:"\\$\\{",
    end:"\\}",keywords:u,contains:[]},N={begin:"html`",end:"",starts:{end:"`",
    returnEnd:!1,contains:[b.BACKSLASH_ESCAPE,_],subLanguage:"xml"}},f={
    begin:"css`",end:"",starts:{end:"`",returnEnd:!1,
    contains:[b.BACKSLASH_ESCAPE,_],subLanguage:"css"}},A={className:"string",
    begin:"`",end:"`",contains:[b.BACKSLASH_ESCAPE,_]},v={className:"comment",
    variants:[b.COMMENT(/\/\*\*(?!\/)/,"\\*/",{relevance:0,contains:[{
    begin:"(?=@[A-Za-z]+)",relevance:0,contains:[{className:"doctag",
    begin:"@[A-Za-z]+"},{className:"type",begin:"\\{",end:"\\}",excludeEnd:!0,
    excludeBegin:!0,relevance:0},{className:"variable",begin:g+"(?=\\s*(-)|$)",
    endsParent:!0,relevance:0},{begin:/(?=[^\n])\s/,relevance:0}]}]
    }),b.C_BLOCK_COMMENT_MODE,b.C_LINE_COMMENT_MODE]
    },p=[b.APOS_STRING_MODE,b.QUOTE_STRING_MODE,N,f,A,y,b.REGEXP_MODE]
    ;_.contains=p.concat({begin:/\{/,end:/\}/,keywords:u,contains:["self"].concat(p)
    });const h=[].concat(v,_.contains),S=h.concat([{begin:/\(/,end:/\)/,keywords:u,
    contains:["self"].concat(h)}]),w={className:"params",begin:/\(/,end:/\)/,
    excludeBegin:!0,excludeEnd:!0,keywords:u,contains:S},R={variants:[{
    match:[/class/,/\s+/,g],scope:{1:"keyword",3:"title.class"}},{
    match:[/extends/,/\s+/,l(g,"(",l(/\./,g),")*")],scope:{1:"keyword",
    3:"title.class.inherited"}}]},O={relevance:0,
    match:/\b[A-Z][a-z]+([A-Z][a-z]+)*/,className:"title.class",keywords:{
    _:[...t,...s]}},I={variants:[{match:[/function/,/\s+/,g,/(?=\s*\()/]},{
    match:[/function/,/\s*(?=\()/]}],className:{1:"keyword",3:"title.function"},
    label:"func.def",contains:[w],illegal:/%/},T={
    match:l(/\b/,(x=[...r,"super"],l("(?!",x.join("|"),")")),g,o(/\(/)),
    className:"title.function",relevance:0};var x;const M={
    begin:l(/\./,o(l(g,/(?![0-9A-Za-z$_(])/))),end:g,excludeBegin:!0,
    keywords:"prototype",className:"property",relevance:0},k={
    match:[/get|set/,/\s+/,g,/(?=\()/],className:{1:"keyword",3:"title.function"},
    contains:[{begin:/\(\)/},w]
    },C="(\\([^()]*(\\([^()]*(\\([^()]*\\)[^()]*)*\\)[^()]*)*\\)|"+b.UNDERSCORE_IDENT_RE+")\\s*=>",B={
    match:[/const|var|let/,/\s+/,g,/\s*/,/=\s*/,o(C)],className:{1:"keyword",
    3:"title.function"},contains:[w]};return{name:"Javascript",
    aliases:["js","jsx","mjs","cjs"],keywords:u,exports:{PARAMS_CONTAINS:S},
    illegal:/#(?![$_A-z])/,contains:[b.SHEBANG({label:"shebang",binary:"node",
    relevance:5}),{label:"use_strict",className:"meta",relevance:10,
    begin:/^\s*['"]use (strict|asm)['"]/
    },b.APOS_STRING_MODE,b.QUOTE_STRING_MODE,N,f,A,v,y,O,{className:"attr",
    begin:g+o(":"),relevance:0},B,{
    begin:"("+b.RE_STARTERS_RE+"|\\b(case|return|throw)\\b)\\s*",
    keywords:"return throw case",relevance:0,contains:[v,b.REGEXP_MODE,{
    className:"function",begin:C,returnBegin:!0,end:"\\s*=>",contains:[{
    className:"params",variants:[{begin:b.UNDERSCORE_IDENT_RE,relevance:0},{
    className:null,begin:/\(\s*\)/,skip:!0},{begin:/\(/,end:/\)/,excludeBegin:!0,
    excludeEnd:!0,keywords:u,contains:S}]}]},{begin:/,/,relevance:0},{match:/\s+/,
    relevance:0},{variants:[{begin:"<>",end:"</>"},{begin:d.begin,
    "on:begin":d.isTrulyOpeningTag,end:d.end}],subLanguage:"xml",contains:[{
    begin:d.begin,end:d.end,skip:!0,contains:["self"]}]}]},I,{
    beginKeywords:"while if switch catch for"},{
    begin:"\\b(?!function)"+b.UNDERSCORE_IDENT_RE+"\\([^()]*(\\([^()]*(\\([^()]*\\)[^()]*)*\\)[^()]*)*\\)\\s*\\{",
    returnBegin:!0,label:"func.def",contains:[w,b.inherit(b.TITLE_MODE,{begin:g,
    className:"title.function"})]},{match:/\.\.\./,relevance:0},M,{match:"\\$"+g,
    relevance:0},{match:[/\bconstructor(?=\s*\()/],className:{1:"title.function"},
    contains:[w]},T,{relevance:0,match:/\b[A-Z][A-Z_]+\b/,
    className:"variable.constant"},R,k,{match:/\$[(.]/}]}}})());hljs.registerLanguage("swift",(()=>{"use strict";function e(e){
    return e?"string"==typeof e?e:e.source:null}function a(e){return t("(?=",e,")")}
    function t(...a){return a.map((a=>e(a))).join("")}function n(...a){
    return"("+((e=>{const a=e[e.length-1]
    ;return"object"==typeof a&&a.constructor===Object?(e.splice(e.length-1,1),a):{}
    })(a).capture?"":"?:")+a.map((a=>e(a))).join("|")+")"}
    const i=e=>t(/\b/,e,/\w$/.test(e)?/\b/:/\B/),s=["Protocol","Type"].map(i),u=["init","self"].map(i),c=["Any","Self"],r=["actor","associatedtype","async","await",/as\?/,/as!/,"as","break","case","catch","class","continue","convenience","default","defer","deinit","didSet","do","dynamic","else","enum","extension","fallthrough",/fileprivate\(set\)/,"fileprivate","final","for","func","get","guard","if","import","indirect","infix",/init\?/,/init!/,"inout",/internal\(set\)/,"internal","in","is","lazy","let","mutating","nonmutating",/open\(set\)/,"open","operator","optional","override","postfix","precedencegroup","prefix",/private\(set\)/,"private","protocol",/public\(set\)/,"public","repeat","required","rethrows","return","set","some","static","struct","subscript","super","switch","throws","throw",/try\?/,/try!/,"try","typealias",/unowned\(safe\)/,/unowned\(unsafe\)/,"unowned","var","weak","where","while","willSet"],o=["false","nil","true"],l=["assignment","associativity","higherThan","left","lowerThan","none","right"],m=["#colorLiteral","#column","#dsohandle","#else","#elseif","#endif","#error","#file","#fileID","#fileLiteral","#filePath","#function","#if","#imageLiteral","#keyPath","#line","#selector","#sourceLocation","#warn_unqualified_access","#warning"],p=["abs","all","any","assert","assertionFailure","debugPrint","dump","fatalError","getVaList","isKnownUniquelyReferenced","max","min","numericCast","pointwiseMax","pointwiseMin","precondition","preconditionFailure","print","readLine","repeatElement","sequence","stride","swap","swift_unboxFromSwiftValueWithType","transcode","type","unsafeBitCast","unsafeDowncast","withExtendedLifetime","withUnsafeMutablePointer","withUnsafePointer","withVaList","withoutActuallyEscaping","zip"],F=n(/[/=\-+!*%<>&|^~?]/,/[\u00A1-\u00A7]/,/[\u00A9\u00AB]/,/[\u00AC\u00AE]/,/[\u00B0\u00B1]/,/[\u00B6\u00BB\u00BF\u00D7\u00F7]/,/[\u2016-\u2017]/,/[\u2020-\u2027]/,/[\u2030-\u203E]/,/[\u2041-\u2053]/,/[\u2055-\u205E]/,/[\u2190-\u23FF]/,/[\u2500-\u2775]/,/[\u2794-\u2BFF]/,/[\u2E00-\u2E7F]/,/[\u3001-\u3003]/,/[\u3008-\u3020]/,/[\u3030]/),d=n(F,/[\u0300-\u036F]/,/[\u1DC0-\u1DFF]/,/[\u20D0-\u20FF]/,/[\uFE00-\uFE0F]/,/[\uFE20-\uFE2F]/),b=t(F,d,"*"),h=n(/[a-zA-Z_]/,/[\u00A8\u00AA\u00AD\u00AF\u00B2-\u00B5\u00B7-\u00BA]/,/[\u00BC-\u00BE\u00C0-\u00D6\u00D8-\u00F6\u00F8-\u00FF]/,/[\u0100-\u02FF\u0370-\u167F\u1681-\u180D\u180F-\u1DBF]/,/[\u1E00-\u1FFF]/,/[\u200B-\u200D\u202A-\u202E\u203F-\u2040\u2054\u2060-\u206F]/,/[\u2070-\u20CF\u2100-\u218F\u2460-\u24FF\u2776-\u2793]/,/[\u2C00-\u2DFF\u2E80-\u2FFF]/,/[\u3004-\u3007\u3021-\u302F\u3031-\u303F\u3040-\uD7FF]/,/[\uF900-\uFD3D\uFD40-\uFDCF\uFDF0-\uFE1F\uFE30-\uFE44]/,/[\uFE47-\uFEFE\uFF00-\uFFFD]/),f=n(h,/\d/,/[\u0300-\u036F\u1DC0-\u1DFF\u20D0-\u20FF\uFE20-\uFE2F]/),w=t(h,f,"*"),y=t(/[A-Z]/,f,"*"),g=["autoclosure",t(/convention\(/,n("swift","block","c"),/\)/),"discardableResult","dynamicCallable","dynamicMemberLookup","escaping","frozen","GKInspectable","IBAction","IBDesignable","IBInspectable","IBOutlet","IBSegueAction","inlinable","main","nonobjc","NSApplicationMain","NSCopying","NSManaged",t(/objc\(/,w,/\)/),"objc","objcMembers","propertyWrapper","requires_stored_property_inits","resultBuilder","testable","UIApplicationMain","unknown","usableFromInline"],E=["iOS","iOSApplicationExtension","macOS","macOSApplicationExtension","macCatalyst","macCatalystApplicationExtension","watchOS","watchOSApplicationExtension","tvOS","tvOSApplicationExtension","swift"]
    ;return e=>{const F={match:/\s+/,relevance:0},h=e.COMMENT("/\\*","\\*/",{
    contains:["self"]}),v=[e.C_LINE_COMMENT_MODE,h],A={match:[/\./,n(...s,...u)],
    className:{2:"keyword"}},N={match:t(/\./,n(...r)),relevance:0
    },C=r.filter((e=>"string"==typeof e)).concat(["_|0"]),D={variants:[{
    className:"keyword",
    match:n(...r.filter((e=>"string"!=typeof e)).concat(c).map(i),...u)}]},k={
    $pattern:n(/\b\w+/,/#\w+/),keyword:C.concat(m),literal:o},B=[A,N,D],_=[{
    match:t(/\./,n(...p)),relevance:0},{className:"built_in",
    match:t(/\b/,n(...p),/(?=\()/)}],S={match:/->/,relevance:0},M=[S,{
    className:"operator",relevance:0,variants:[{match:b},{match:`\\.(\\.|${d})+`}]
    }],x="([0-9a-fA-F]_*)+",I={className:"number",relevance:0,variants:[{
    match:"\\b(([0-9]_*)+)(\\.(([0-9]_*)+))?([eE][+-]?(([0-9]_*)+))?\\b"},{
    match:`\\b0x(${x})(\\.(${x}))?([pP][+-]?(([0-9]_*)+))?\\b`},{
    match:/\b0o([0-7]_*)+\b/},{match:/\b0b([01]_*)+\b/}]},L=(e="")=>({
    className:"subst",variants:[{match:t(/\\/,e,/[0\\tnr"']/)},{
    match:t(/\\/,e,/u\{[0-9a-fA-F]{1,8}\}/)}]}),O=(e="")=>({className:"subst",
    match:t(/\\/,e,/[\t ]*(?:[\r\n]|\r\n)/)}),T=(e="")=>({className:"subst",
    label:"interpol",begin:t(/\\/,e,/\(/),end:/\)/}),$=(e="")=>({begin:t(e,/"""/),
    end:t(/"""/,e),contains:[L(e),O(e),T(e)]}),j=(e="")=>({begin:t(e,/"/),
    end:t(/"/,e),contains:[L(e),T(e)]}),P={className:"string",
    variants:[$(),$("#"),$("##"),$("###"),j(),j("#"),j("##"),j("###")]},K={
    match:t(/`/,w,/`/)},z=[K,{className:"variable",match:/\$\d+/},{
    className:"variable",match:`\\$${f}+`}],q=[{match:/(@|#)available/,
    className:"keyword",starts:{contains:[{begin:/\(/,end:/\)/,keywords:E,
    contains:[...M,I,P]}]}},{className:"keyword",match:t(/@/,n(...g))},{
    className:"meta",match:t(/@/,w)}],U={match:a(/\b[A-Z]/),relevance:0,contains:[{
    className:"type",
    match:t(/(AV|CA|CF|CG|CI|CL|CM|CN|CT|MK|MP|MTK|MTL|NS|SCN|SK|UI|WK|XC)/,f,"+")
    },{className:"type",match:y,relevance:0},{match:/[?!]+/,relevance:0},{
    match:/\.\.\./,relevance:0},{match:t(/\s+&\s+/,a(y)),relevance:0}]},Z={
    begin:/</,end:/>/,keywords:k,contains:[...v,...B,...q,S,U]};U.contains.push(Z)
    ;const V={begin:/\(/,end:/\)/,relevance:0,keywords:k,contains:["self",{
    match:t(w,/\s*:/),keywords:"_|0",relevance:0
    },...v,...B,..._,...M,I,P,...z,...q,U]},W={begin:/</,end:/>/,contains:[...v,U]
    },G={begin:/\(/,end:/\)/,keywords:k,contains:[{
    begin:n(a(t(w,/\s*:/)),a(t(w,/\s+/,w,/\s*:/))),end:/:/,relevance:0,contains:[{
    className:"keyword",match:/\b_\b/},{className:"params",match:w}]
    },...v,...B,...M,I,P,...q,U,V],endsParent:!0,illegal:/["']/},R={
    match:[/func/,/\s+/,n(K.match,w,b)],className:{1:"keyword",3:"title.function"},
    contains:[W,G,F],illegal:[/\[/,/%/]},X={
    match:[/\b(?:subscript|init[?!]?)/,/\s*(?=[<(])/],className:{1:"keyword"},
    contains:[W,G,F],illegal:/\[|%/},H={match:[/operator/,/\s+/,b],className:{
    1:"keyword",3:"title"}},J={begin:[/precedencegroup/,/\s+/,y],className:{
    1:"keyword",3:"title"},contains:[U],keywords:[...l,...o],end:/}/}
    ;for(const e of P.variants){const a=e.contains.find((e=>"interpol"===e.label))
    ;a.keywords=k;const t=[...B,..._,...M,I,P,...z];a.contains=[...t,{begin:/\(/,
    end:/\)/,contains:["self",...t]}]}return{name:"Swift",keywords:k,
    contains:[...v,R,X,{beginKeywords:"struct protocol class extension enum actor",
    end:"\\{",excludeEnd:!0,keywords:k,contains:[e.inherit(e.TITLE_MODE,{
    className:"title.class",begin:/[A-Za-z$_][\u00C0-\u02B80-9A-Za-z$_]*/}),...B]
    },H,J,{beginKeywords:"import",end:/$/,contains:[...v],relevance:0
    },...B,..._,...M,I,P,...z,...q,U,V]}}})());hljs.registerLanguage("dockerfile",(()=>{"use strict";return e=>({
    name:"Dockerfile",aliases:["docker"],case_insensitive:!0,
    keywords:["from","maintainer","expose","env","arg","user","onbuild","stopsignal"],
    contains:[e.HASH_COMMENT_MODE,e.APOS_STRING_MODE,e.QUOTE_STRING_MODE,e.NUMBER_MODE,{
    beginKeywords:"run cmd entrypoint volume add copy workdir label healthcheck shell",
    starts:{end:/[^\\]$/,subLanguage:"bash"}}],illegal:"</"})})());hljs.registerLanguage("sql",(()=>{"use strict";function e(e){
    return e?"string"==typeof e?e:e.source:null}function r(...r){
    return r.map((r=>e(r))).join("")}function t(...r){return"("+((e=>{
    const r=e[e.length-1]
    ;return"object"==typeof r&&r.constructor===Object?(e.splice(e.length-1,1),r):{}
    })(r).capture?"":"?:")+r.map((r=>e(r))).join("|")+")"}return e=>{
    const n=e.COMMENT("--","$"),a=["true","false","unknown"],i=["bigint","binary","blob","boolean","char","character","clob","date","dec","decfloat","decimal","float","int","integer","interval","nchar","nclob","national","numeric","real","row","smallint","time","timestamp","varchar","varying","varbinary"],s=["abs","acos","array_agg","asin","atan","avg","cast","ceil","ceiling","coalesce","corr","cos","cosh","count","covar_pop","covar_samp","cume_dist","dense_rank","deref","element","exp","extract","first_value","floor","json_array","json_arrayagg","json_exists","json_object","json_objectagg","json_query","json_table","json_table_primitive","json_value","lag","last_value","lead","listagg","ln","log","log10","lower","max","min","mod","nth_value","ntile","nullif","percent_rank","percentile_cont","percentile_disc","position","position_regex","power","rank","regr_avgx","regr_avgy","regr_count","regr_intercept","regr_r2","regr_slope","regr_sxx","regr_sxy","regr_syy","row_number","sin","sinh","sqrt","stddev_pop","stddev_samp","substring","substring_regex","sum","tan","tanh","translate","translate_regex","treat","trim","trim_array","unnest","upper","value_of","var_pop","var_samp","width_bucket"],o=["create table","insert into","primary key","foreign key","not null","alter table","add constraint","grouping sets","on overflow","character set","respect nulls","ignore nulls","nulls first","nulls last","depth first","breadth first"],c=s,l=["abs","acos","all","allocate","alter","and","any","are","array","array_agg","array_max_cardinality","as","asensitive","asin","asymmetric","at","atan","atomic","authorization","avg","begin","begin_frame","begin_partition","between","bigint","binary","blob","boolean","both","by","call","called","cardinality","cascaded","case","cast","ceil","ceiling","char","char_length","character","character_length","check","classifier","clob","close","coalesce","collate","collect","column","commit","condition","connect","constraint","contains","convert","copy","corr","corresponding","cos","cosh","count","covar_pop","covar_samp","create","cross","cube","cume_dist","current","current_catalog","current_date","current_default_transform_group","current_path","current_role","current_row","current_schema","current_time","current_timestamp","current_path","current_role","current_transform_group_for_type","current_user","cursor","cycle","date","day","deallocate","dec","decimal","decfloat","declare","default","define","delete","dense_rank","deref","describe","deterministic","disconnect","distinct","double","drop","dynamic","each","element","else","empty","end","end_frame","end_partition","end-exec","equals","escape","every","except","exec","execute","exists","exp","external","extract","false","fetch","filter","first_value","float","floor","for","foreign","frame_row","free","from","full","function","fusion","get","global","grant","group","grouping","groups","having","hold","hour","identity","in","indicator","initial","inner","inout","insensitive","insert","int","integer","intersect","intersection","interval","into","is","join","json_array","json_arrayagg","json_exists","json_object","json_objectagg","json_query","json_table","json_table_primitive","json_value","lag","language","large","last_value","lateral","lead","leading","left","like","like_regex","listagg","ln","local","localtime","localtimestamp","log","log10","lower","match","match_number","match_recognize","matches","max","member","merge","method","min","minute","mod","modifies","module","month","multiset","national","natural","nchar","nclob","new","no","none","normalize","not","nth_value","ntile","null","nullif","numeric","octet_length","occurrences_regex","of","offset","old","omit","on","one","only","open","or","order","out","outer","over","overlaps","overlay","parameter","partition","pattern","per","percent","percent_rank","percentile_cont","percentile_disc","period","portion","position","position_regex","power","precedes","precision","prepare","primary","procedure","ptf","range","rank","reads","real","recursive","ref","references","referencing","regr_avgx","regr_avgy","regr_count","regr_intercept","regr_r2","regr_slope","regr_sxx","regr_sxy","regr_syy","release","result","return","returns","revoke","right","rollback","rollup","row","row_number","rows","running","savepoint","scope","scroll","search","second","seek","select","sensitive","session_user","set","show","similar","sin","sinh","skip","smallint","some","specific","specifictype","sql","sqlexception","sqlstate","sqlwarning","sqrt","start","static","stddev_pop","stddev_samp","submultiset","subset","substring","substring_regex","succeeds","sum","symmetric","system","system_time","system_user","table","tablesample","tan","tanh","then","time","timestamp","timezone_hour","timezone_minute","to","trailing","translate","translate_regex","translation","treat","trigger","trim","trim_array","true","truncate","uescape","union","unique","unknown","unnest","update","upper","user","using","value","values","value_of","var_pop","var_samp","varbinary","varchar","varying","versioning","when","whenever","where","width_bucket","window","with","within","without","year","add","asc","collation","desc","final","first","last","view"].filter((e=>!s.includes(e))),u={
    begin:r(/\b/,t(...c),/\s*\(/),relevance:0,keywords:{built_in:c}};return{
    name:"SQL",case_insensitive:!0,illegal:/[{}]|<\//,keywords:{
    $pattern:/\b[\w\.]+/,keyword:((e,{exceptions:r,when:t}={})=>{const n=t
    ;return r=r||[],e.map((e=>e.match(/\|\d+$/)||r.includes(e)?e:n(e)?e+"|0":e))
    })(l,{when:e=>e.length<3}),literal:a,type:i,
    built_in:["current_catalog","current_date","current_default_transform_group","current_path","current_role","current_schema","current_transform_group_for_type","current_user","session_user","system_time","system_user","current_time","localtime","current_timestamp","localtimestamp"]
    },contains:[{begin:t(...o),relevance:0,keywords:{$pattern:/[\w\.]+/,
    keyword:l.concat(o),literal:a,type:i}},{className:"type",
    begin:t("double precision","large object","with timezone","without timezone")
    },u,{className:"variable",begin:/@[a-z0-9]+/},{className:"string",variants:[{
    begin:/'/,end:/'/,contains:[{begin:/''/}]}]},{begin:/"/,end:/"/,contains:[{
    begin:/""/}]},e.C_NUMBER_MODE,e.C_BLOCK_COMMENT_MODE,n,{className:"operator",
    begin:/[-+*/=%^~]|&&?|\|\|?|!=?|<(?:=>?|<|>)?|>[>=]?/,relevance:0}]}}})());