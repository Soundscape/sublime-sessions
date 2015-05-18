(function(){var t,e,r,n,o,i,u=function(t,e){function r(){this.constructor=t}for(var n in e)s.call(e,n)&&(t[n]=e[n]);return r.prototype=e.prototype,t.prototype=new r,t.__super__=e.prototype,t},s={}.hasOwnProperty;n=require("lodash"),o=require("hellojs"),r=require("when"),t=require("sublime-core"),i={unauthenticated:{signIn:function(t,e){o(t.network).login({force:!1},function(r){return function(n){return n.error?e.reject(n.error):(t._data=n,r.setMachineState(r.authenticated),e.resolve(t))}}(this))}},authenticated:{signOut:function(t,e){o(t.network).logout(function(r){return function(n){return n.error?e.reject(n.error):(t._data=null,t._profile=null,r.setMachineState(r.unauthenticated),e.resolve(t))}}(this))},profile:function(t,e){o(t.network).api("/me").then(function(r){return r.error?e.reject(r.error):(t._profile=r,e.resolve(r))})}}},e=function(t){function e(t){e.__super__.constructor.call(this,i),this.network=t}return u(e,t),e.prototype.signIn=function(){var t;return t=r.defer(),this.apply("signIn",this,t),t.promise},e.prototype.signOut=function(){var t;return t=r.defer(),this.apply("signOut",this,t),t.promise},e.prototype.profile=function(){var t;return t=r.defer(),this.apply("profile",this,t),t.promise},e.prototype.isAvailable=function(){var t,e;return t=o(this.network).getAuthResponse(),e=(new Date).getTime()/1e3,t&&t.access_token&&t.expires>e},e.prototype.isActive=function(){return"authenticated"===this.state()&&this.isAvailable()},e}(t.Stateful),module.exports=e}).call(this);
