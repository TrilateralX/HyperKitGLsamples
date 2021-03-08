// Generated by Haxe 4.3.0-rc.1+5f599ba
(function ($global) { "use strict";
function $extend(from, fields) {
	var proto = Object.create(from);
	for (var name in fields) proto[name] = fields[name];
	if( fields.toString !== Object.prototype.toString ) proto.toString = fields.toString;
	return proto;
}
var dummy_Base = function(width_,height_,hasImage,animate) {
	if(animate == null) {
		animate = true;
	}
	if(hasImage == null) {
		hasImage = true;
	}
	this.hasImage = true;
	animate = this.animate;
	this.width = width_;
	this.height = height_;
	this.hasImage = hasImage;
	if(!hasImage) {
		this.setup();
	}
};
dummy_Base.prototype = {
	setup: function() {
		console.log("dummy/Base.hx:23:","setup");
	}
};
var Test = function(width_,height_,hasImage,animate) {
	dummy_Base.call(this,width_,height_,hasImage,animate);
};
Test.__super__ = dummy_Base;
Test.prototype = $extend(dummy_Base.prototype,{
});
function Test_main() {
	new Test(1000,1000,false);
}
var haxe_iterators_ArrayIterator = function(array) {
	this.current = 0;
	this.array = array;
};
haxe_iterators_ArrayIterator.prototype = {
	hasNext: function() {
		return this.current < this.array.length;
	}
	,next: function() {
		return this.array[this.current++];
	}
};
Test_main();
})({});
