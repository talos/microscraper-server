/**
*
* JavaScript to auto-generate a disable switch for inputs.
*
* This disable switch does not take advantage of the default exclusivity of radio buttons, because
* it has no name attribute.  This also means that it does not affect the serialization of the form
* it is inside.
**/
(function( $ ) {
    var ns = 'disabler',
    
    settings = {
	on : 'On',
	off : 'Off'
    },

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
			data = {
			    'switch' : $('<div>').css({'float': 'right'})
				.append($('<label>').text(options.on).attr('for', name))
				.append($('<input>')
					.attr({type: 'radio', checked: !$input.attr('disabled') })
					.addClass(ns + '_on')
					.click(function() {
					    $('input.' + ns +'_off', data['switch']).attr('checked', false);
					    $input.attr('disabled', false).show();
					}))
				.append($('<br />'))
				.append($('<label>').text(options.off).attr('for', name))
				.append($('<input>')
					.attr({type: 'radio', checked: $input.attr('disabled') } )
					.addClass(ns + '_off')
					.click(function() {
					    $('input.' + ns + '_on', data['switch']).attr('checked', false);
					    $input.attr('disabled', true).hide();
					})),
			    container : $('<div>').css({'float' : 'left' } ),
			    parent : $input.parent(),
			    originalState : $input.attr('disabled')
			};
			if(data.originalState == true) {
			    $input.hide();
			}
			$input.data(ns, data);
			$input.detach();
			data.parent.append(data.container.append($input)).append(data['switch']);
		    }
		}
	    });
	},

	remove : function(options) {
	    return this.each(function() {
		var data = $(this).data(ns);
		if(data) {
		    $(this).detach().appendTo(data.parent).attr('disabled', data.originalState).show();
		    data.container.remove();
		    data['switch'].remove();
		    $(this).removeData(ns);
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
