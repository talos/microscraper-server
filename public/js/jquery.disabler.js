/**
*
* JavaScript to auto-generate a disable switch for inputs.
*
**/

(function( $ ) {
    var ns = 'disabler',
    
    methods = {
	init : function (options) {
	    return this.each(function() {
		// Only applies to textarea, input, and button elements
		if($(this).is('textarea, input, button')) {
		    // Only apply to elements without it.
		    if(!$(this).data(ns)) {
			var elems = {
			    enabled: $('<input>').value('On'),
			    disabled: $('<input>').value('Off')
			};
			$(this).after($enabled).after($disabled);
		    }
		}
	    });
	},

	remove : function(options) {
	    return this.each(function() {
		var data = $(this).data(ns);
		if(data) {
		    $.each(data.elems, function (name, $elem) {
			$elem.remove();
		    });
		}
	    });
	}
    };

    $.fn[ns] = function(methodd) {
	if ( methods[method] ) {
	    return methods[ method ].apply( this, Array.prototype.slice.call( arguments, 1 ));
	} else if ( typeof method === 'object' || ! method ) {
	    return methods.init.apply( this, arguments );
	} else {
	    $.error( 'Method ' +  method + ' does not exist in' + ns + '.' );
	}
    };
} ( jQuery ) )