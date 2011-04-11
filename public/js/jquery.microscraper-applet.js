/**
*
* JavaScript to handle interactions with the MicroScraper Applet.
*
* Depends upon jquery.spinner.
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
	updateFrequency : 100
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
	addResult : function($form, obj) {
	    if(obj) {
		var $results = $form.data(ns).elems.results;
		for( key in obj ) {
		    $results.prepend($('<tr>')
				     .append($('<td>').addClass('ref').text(key + ': '))
				     .append($('<td>').addClass('value').text(obj[key])));
		}
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
		height : options.height
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
			    results : $('<table />').addClass('results'),

			    // Add Test (submit) button
			    test : $('<button type="submit" />').text(data.options.test),
			    
			    // Add Stop button
			    stop : $('<button type="button" />').text(data.options.stop).attr('disabled', true)
				.click(function() { $form.microscraper_applet('stop'); } ),

			    // Clear button
			    clear : $('<button type="button" />').text(data.options.clear)
				.click(function() { $form.data(ns).elems.log.empty(); }),
			    
			    log : $('<div />').addClass('log')
			};
			
			$.each(data.elems, function(name, elem) {
			    $form.append(elem);
			});
			
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
		    param1 = data.options.location, // need an absolute url.
		    param2 = $form.serialize();
		    
		    // Attach and load applet if this has not yet been done.
		    if(!data.applet) {
			if(data.applet_elem.parent().size() === 0) {
			    data.applet_elem.appendTo($('body'));
			}
			data.applet = data.applet_elem.get(0);
		    }
		    
		    // We should now have an applet.  If it's not running, start it up and disable the test button.
		    var prevResults = null,
		    started = false;
		    data.running = setInterval(function() {
			try {
			    if(data.applet.isAlive() === false && started === false) {
				started = true;
				data.applet.start(param1, param2);
				helpers.log($form, {info : 'Testing JSON at ' + param1 + ' with defaults ' + param2});
				data.elems.test.attr('disabled', true);
				data.elems.stop.attr('disabled', false);
				$form.data(ns).elems.results.empty();
			    }
			    $form.microscraper_applet('update');
			    if(data.applet.isAlive() === false && started === true) {
				clearInterval(data.running);
				helpers.log($form, { info: 'Finished.' });
				$form.microscraper_applet('stop');
			    }
			} catch (e) {
			    if(e instanceof TypeError) {
				console.log(e);
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
			    data.applet.kill();
			    helpers.log($form, { info : 'Stopped.'} );
			}
			$form.microscraper_applet('update');
			data.elems.test.attr('disabled', false);
			data.elems.stop.attr('disabled', true);
		    }
		}
	    });
	},
	
	update : function(options) {
	    return this.each(function() {
		var data = $(this).data(ns),
		$form = $(this);
		if(data) {
		    var result = data.applet.results();
		    while( result ) {
			helpers.addResult( $form, $.parseJSON(result) );
			result = data.applet.results();
		    }
		    var log = data.applet.log();
		    while( log ) {
			helpers.log( $form, $.parseJSON(log) );
			log = data.applet.log();
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