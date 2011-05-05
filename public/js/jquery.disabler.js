/**
*
* JavaScript to auto-generate a disable switch for inputs.
*
**/
(function( $ ) {
    var ns = 'disabler',
    
    settings = {},

    methods = {
	init : function (options) {
	    return this.each(function() {
		// Only applies to textarea, input, and button elements
		if($(this).is('textarea, input, button')) {
		    // Only apply to elements without it.
		    if(!$(this).data(ns)) {
			options = $.extend(settings, options);
			var $input = $(this),
			name = $input.attr('name') + '_disabler',
			$label = $input.closest('form').find('label[for="' + $input.attr('name') + '"]'),
			data = {
			    checkbox : $('<input>').css('display','inline')
					.attr({type: 'checkbox', checked: !$input.is(':disabled') })
					.click(function() {
					    $input.disabler('update');
					}),
			    originalState : $input.is(':disabled')
			};
			$input.data(ns, data);
			$label.before(data.checkbox);
			$input.disabler('update');
		    }
		}
	    });
	},
	update : function (options) {
	    return this.each(function() {
		if($(this).data(ns)) {
		    var $input = $(this),
		    data = $input.data(ns);
		    if(data.checkbox.is(':checked')) {
			$input.attr('disabled', false).show();
		    } else {
			$input.attr('disabled', true).hide();
		    }
		}
	    });
	},

	remove : function(options) {
	    return this.each(function() {
		var data = $(this).data(ns);
		if(data) {
		    data.checkbox.remove();
		    $(this).attr('disabled', data.originalState).removeData(ns);
		}
	    });
	}
    };

    $.fn[ns] = function(method) {
	if ( methods[method] ) {
	    return methods[ method ].apply( this, Array.prototype.slice.call( arguments, 1 ));
	} else if ( typeof method === 'object' || ! method ) {
	    return methods.init.apply( this, arguments );
	} else {
	    $.error( 'Method ' +  method + ' does not exist in' + ns + '.' );
	}
    };
} ( jQuery ) );
