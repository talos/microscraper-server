/**
*
* JavaScript to handle interactions with the MicroScraper Applet.
*
**/

(function( $ ) {
    var ns = 'microscraper_applet',
    settings = {
	location : $(location).attr('href') + '?format=json',
	width : "0",
	height : "0",
	test : 'Test',
	stop : 'Stop',
	clear: 'Clear Log',
	updateFrequency : 100,
	spinner_src : '/img/spinner.gif',
	spinner_width : 16,
	spinner_height : 16
    },
    
    helpers = {
	log : function($form, obj) {
	    if(obj) {
		var $log = $form.data(ns).elems.log;
		for( key in obj ) {
		    $log.prepend($('<div>').addClass(key).text(obj[key]));
		}
	    }
	},
	clearExecutions: function($form) {
	    var $executions = $form.data(ns).elems.executions,
	    $caption = $('<caption>').text('Executions'),
	    $headers = $('<tr>')
		.append($('<th>').text('Source'))
		.append($('<th>').text('ID'))
		.append($('<th>').text('Name'))
		.append($('<th>').text('Value'))
		.append($('<th>').text('Delay'))
		.append($('<th>').text('Failure'));
	    $executions.empty().append($caption).append($headers);
	},
	addExecution : function($form, obj) {
	    if(obj) {
		var $executions = $form.data(ns).elems.executions,
		$execution = $('<tr>').addClass(obj.status);
		
		var key;
		$.each(obj, function(key, value) {
		    var $cell = $('<td />');
		    if($.isArray( value )) {
			$.each( value, function( arrayNum, arrayValue ) {
			    if($.isPlainObject( arrayValue )) {
				$.each( arrayValue, function ( key, value ) {
				    $cell.append ( key + ': ' + value );
				});
			    } else {
				$cell.append($('<pre />').append($('<code />')
								 .text(arrayValue)));
			    }
			});
		    } else {
			$cell.text(value);
		    }
		    $execution.append($cell);
		});
		$executions.append($execution);
	    }
	}
    },
    
    methods = {
	init : function(options) {
	    // Share one applet_elem between all initialized forms.
	    options = $.extend(settings, options);
	    var applet_elem = $('<applet>').attr({
		archive : options.archive,
		codebase : options.codebase,
		code : options.code,
		width : options.width,
		height : options.height,
		mayscript : 'mayscript'
	    });
	    
	    return this.each(function() {
		if($(this).is('form')) {
		    var $form = $(this);
		    // Test to see if this is already initialized.  Do nothing if it is.
		    if(!$form.data(ns)) {
			var data = {};
			$form.data(ns, data);
			
			data.options = options;
			data.applet_elem = applet_elem;
			data.elems = {
			    executions : $('<table />'),

			    // Add Test (submit) button
			    test : $('<button type="submit" />').text(data.options.test),
			    
			    // Add Stop button
			    stop : $('<button type="button" />').text(data.options.stop).attr('disabled', true)
				.click(function() { $form.microscraper_applet('stop'); } ),
			    
			    // Clear button
			    clear : $('<button type="button" />').text(data.options.clear)
				.click(function() { $form.data(ns).elems.log.empty(); }),
			    
			    // Spinner icon
			    spinner : $('<img />').attr({
				src : data.options.spinner_src,
				height: data.options.spinner_height,
				width : data.options.spinner_width
			    }),

			    log : $('<div />').addClass('log')
			};
			
			// Add all the elements
			$.each(data.elems, function(name, elem) {
			    $form.append(elem);
			});
			data.elems.spinner.hide(); // make sure this is hidden to start
			
			$form.submit(function(event) {
			    event.preventDefault();
			    $form.microscraper_applet('start');
			    //return false;
			});
		    }
		}
	    });
	},
	
	start : function(options) {
	    return this.each(function() {
		var data = $(this).data(ns);
		if(data) {
		    var $form = $(this),
		    param1 = data.options.location,
		    started = false; // need an absolute url.
		    var action_ary = $form.attr('action').split('/');
		    action_ary.shift(); // remove leading slash
		    var param2 = unescape(action_ary.shift());
		    param3 = unescape(action_ary.join('/'));
		    param4 = $form.serialize();
		    
		    // Attach and load applet if this has not yet been done.
		    if(!data.applet) {
			if(data.applet_elem.parent().size() === 0) {
			    data.applet_elem.appendTo($('body'));
			}
			data.applet = data.applet_elem.get(0);
		    }
		    
		    // We should now have an applet.  If it's not running, start it up and disable the test button.
		    data.running = setInterval(function() {
			try {
			    if(data.applet.isAlive() === false && started === false) {
				started = true;
				data.applet.start(param1, param2, param3, param4);
				helpers.log($form,{
				    info : 'Testing "' + param2 + '" "' + param3 + '" with JSON from ' + param1 + ' with defaults ' + param4
				});
				data.elems.test.button('disable');
				data.elems.stop.button('enable');
				data.elems.spinner.show();
				$form.data(ns).elems.executions.empty();
			    }
			    $form.microscraper_applet('update');
			    if(data.applet.isAlive() === false && started === true) {
				started = false;
				clearInterval(data.running);
				helpers.log($form, { info: 'Finished.' });
				$form.microscraper_applet('stop');
			    }
			} catch (e) {
			    if(e instanceof TypeError) {
				// User hasn't approved the applet yet.
				//console.log(e);
			    } else {
				$.error(e);
			    }
			}
		    }, data.options.updateFrequency);
		}
	    });
	},

	stop : function(options) {
	    return this.each(function() {
		var data = $(this).data(ns),
		$form = $(this);
		if(data) {
		    // If the applet is running, kill it. Then do cleanup.
		    if(data.applet) {
			if(data.applet.isAlive()) {
			    data.applet.stop();
			}
			$form.microscraper_applet('update');
			data.elems.test.button('enable');
			data.elems.stop.button('disable');
			data.elems.spinner.hide();
		    }
		}
	    });
	},
	
	update : function(options) {
	    return this.each(function() {
		var $form = $(this),
		data = $form.data(ns);
		if(data) {
		    helpers.clearExecutions( $form );
		    data.applet.resetExecutionsIterator();
		    while( data.applet.hasMoreExecutions() ) {
			var execution = data.applet.getNextExecution();
			helpers.addExecution( $form, $.parseJSON(execution) );
		    }
		    while( data.applet.hasMoreLogEntries() ) {
			var logEntry = data.applet.getNextLogEntry();
			helpers.log( $form, $.parseJSON(logEntry) );
		    }
		}
	    });
	},

	destroy : function(options) {
	    return this.each(function() {
		var data = $(this).data(ns);

		// If initialized, remove child elements & data.
		if(data) {
		    $.each(data.elems, function(name, elem) {
			elem.remove();
		    });
		    data = null;
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
} ( jQuery ));