(function($, undefined) {

  $.fn.fancygrid = function(method) {
    if ( methods[method] ) {
      return methods[method].apply( this, Array.prototype.slice.call( arguments, 1 ));
    } else if (typeof(method) === 'object' || !method) {
      return methods.init.apply(this, arguments);
    } else {
      $.error( 'Method ' + method + ' does not exist on jQuery.fancygrid' );
    }
  };

  var methods = {
    init : function(options){
      var settings = { 
        url               : "/", 
        name              : "", 
        query             : { 
          pagination      : { 
            page : (options.paginationPage || 0), 
            per_page : options.paginationPerPage
          },
          columns         : {}, 
          conditions      : {},
          operator        : "any",
          order           : {}
        },
        searchFadeTime    : 25,
        searchFadeOpac    : 0.5,
        searchType        : "simple",
        queries           : 0,
        isStatic          : false,
        gridType          : "table",
        hideTopControl    : false,
        hideBottomControl : false
      }
      options = (options || {});
      $.extend(settings, options);
      
      return this.each(function(){
        var $this = $(this);
        var data = $this.data('fancygrid');
        
        if (!data){
          // initialize fancygrid
          
          // set data
          $this.data('fancygrid', settings);
          
          // hide search tab and controls if wanted
          if (!settings.searchEnabled){
            //$this.find(".js-search").hide();
          }
          
          // Hide the helper stuff
          $(".js-sort-window, .js-sort-content, .js-search-template").hide();
          
          // bind control buttons with functions
          
          // search attribute changed/focused
          $this.find(".js-search input[type='text']").bind("change.fancygrid", function(){
            $(this).parents(".js-fancygrid").fancygrid('newSearch'); 
            return false;
          }).bind("focus.fancygrid", function(){
            $(this).select();
            return false;
          });
          
          // search attribute changed/focused
          $this.find(".js-page").bind("change.fancygrid", function(){
            $(this).parents(".js-fancygrid").fancygrid('page', $(this).val()); 
            return false;
          }).bind("focus.fancygrid", function(){
            $(this).select();
            return false;
          });
          
          // previous page click
          $this.find(".js-previous").bind("click.fancygrid", function(){
            $(this).parents(".js-fancygrid").fancygrid('previousPage'); 
            return false;
          });
          
          // next page click
          $this.find(".js-next").bind("click.fancygrid", function(){
            $(this).parents(".js-fancygrid").fancygrid('nextPage'); 
            return false;
          });
          
          // reload click
          $this.find(".js-reload").bind("click.fancygrid", function(){
            $(this).parents(".js-fancygrid").fancygrid('reloadPage'); 
            return false;
          });
          
          // clear click
          $this.find(".js-clear").bind("click.fancygrid", function(){
            $(this).parents(".js-fancygrid").fancygrid('clearSearch'); 
            return false;
          });
          
          // per page change
          $this.find(".js-per-page").bind("change.fancygrid", function(){
            $(this).parents(".js-fancygrid").fancygrid('perPage', $(this).val()); 
            return false;
          });
          
          // magnifier click
          $this.find(".js-magnify").bind("click.fancygrid", function(){
            $(this).parents(".js-fancygrid").fancygrid('toggleSearch'); 
            return false;
          });
          
          // sort click
          $this.find(".js-sort").bind("click.fancygrid", function(){
            $(this).parents(".js-fancygrid").fancygrid('showSortWindow'); 
            return false;
          });
          
          //extended search submit
          $this.find(".js-search-submit").bind("click.fancygrid", function(){
            $(this).parents(".js-fancygrid").fancygrid('newSearch'); 
            return false;
          });
          
    	    //button remove
    	    $this.find(".js-search-criterion-remove").click(function(){
    	      $(this).parents(".js-search-criterion").remove();
    	    });
    	    
    	    //button add new criterion
    	    $this.find(".js-search-criterion-add").click(function(){
    	      $this.fancygrid("addCriterionRow");
    	    });
          
          // close the sort window if user clicked outside the sortable lists
          $this.find(".js-sort-content").click(function(){
            $this.fancygrid("closeSortWindow");
          });
          $this.find(".js-sortable").click(function(e){
            e.stopPropagation();
          });
          
        } else {
          // nothing to do when fancygrid is already initialized
          $.extend(data, options);
        }
      });
    },
    //
    // removes the plugin and clears the attached data
    //
    destroy : function(){
      return this.each(function(){
        var $this = $(this);
        data = $this.data('fancygrid');
        $this.unbind('.fancygrid');
        $this.removeData('fancygrid');
      });
    },
    //
    // Fills the fancygrid query data with search conditions
    //
    setupConditions : function(){
      var $this = $(this);
      var data = $this.data('fancygrid');
      
      var $this = $(this);
      data = $this.data('fancygrid');
      data.query.conditions = {};
      
      if (data.searchType == "simple"){
        
        // process simple search
        
        $(this).find(".js-attribute").each(function(){
          data.query.conditions[$(this).attr("name")] = $(this).val();
        });
      } else {
        
        // process complex search
        
        data.query.operator = $this.find(".js-search-conditions:checked").val() || "any";

        $this.find("ul.js-search-criteria li.js-search-criterion").each(function(){
          var column_name = $(this).find("select[name='column_name']").val();
          var operator  = $(this).find("select[name='operator']").val();
          var value = $(this).find("input[name='column_value']").val();
          
          if (typeof(data.query.conditions[column_name]) == "undefined"){
            data.query.conditions[column_name] = [];
          }
          
          data.query.conditions[column_name].push({
            operator : operator,
            value : value
          })
        }); 
      }
    },
    //
    // Fills the fancygrid query data with emputy search conditions
    //
    setupEmptyConditions : function(){
      var $this = $(this);
      var data = $this.data('fancygrid');
      
      data.query.conditions = {};
    },
    //
    // Fills the fancygrid query data with pagination conditions
    //
    setupPagination : function(page, perPage){
      var $this = $(this);
      var data = $this.data('fancygrid');
      
      data.query.pagination = { page : 0, per_page : 20 };
      if(!isNaN(Number(page)) && Number(page) >= 0){
        data.query.pagination.page = page;
      }
      if (!isNaN(Number(perPage)) && Number(perPage) > 0){
        data.query.pagination.per_page = perPage;
      }
    },
    setupOrder : function(){
      var $this = $(this);
      var data = $this.data('fancygrid');
      var order = {};
      var column = $this.find("th.js-orderable[order='ASC'], th.js-orderable[order='DESC']");
      
      if (column.length > 0){
        order.table = column.attr("table");
        order.column = column.attr("column");
        order.direction = column.attr("order");        
      }

      data.query.order = order;
    },
    //
    // Fills the fancygrid query data with column order and column visibility conditions
    //
    setupColumns : function(){
      var $this = $(this);
      var data = $this.data('fancygrid');
      var columns = {}
      
      var visibleArray = $this.find('.js-sortable-visible li:not(.js-not-sortable)');
      var hiddenArray = $this.find('.js-sortable-hidden li:not(.js-not-sortable)');
      
      var index = 0;
      $(visibleArray).each(function(){
        columns[$(this).attr("id")] = {
          visible : true,
          position : index
        };
        index += 1;
      });
      $(hiddenArray).each(function(){
        columns[$(this).attr("id")] = {
          visible : false,
          position : index
        };
        index += 1;
      });
      
      data.query.columns = columns;
    },
    order : function(){
      return "";
    },
    search : function(){
      var $this = $(this);
      var $content = $this.find(".js-tablewrapper");
      var $control = $this.find(".js-tablecontrol");
      var data = $this.data('fancygrid');
      data.queries += 1;
      
      $control.find(".js-reload").addClass("loading");
      $this.fadeTo(data.searchFadeTime, data.searchFadeOpac);
      
      queryData = { "fancygrid" : {} };
      queryData["fancygrid"][data.name] = data.query;
      
      $.ajax({
        type      : "GET",
        url       : data.url,
        data      : queryData,
        dataType  : "html",
        success   : function(result){  
          data.queries -= 1;
          if(data.queries == 0){
            $this.fancygrid("replaceContent", $(result).find(".js-tablewrapper"));
            
            $control.find(".js-per-page").val(data.query.pagination.per_page);
            $control.find(".js-page").val(Number(data.query.pagination.page) + 1);
            
            total = (Number($(result).find(".js-result-total").html()));
            totalPages = total / data.query.pagination.per_page
            totalPages = (totalPages | 0) + 1;

            $control.find(".js-page-total").text(totalPages);
            $control.find(".js-result-total").html(total);
            
            $this.fadeTo(data.searchFadeTime, 1.0, function(){
              $control.find(".js-reload").removeClass("loading");
            }); 
          }
          $this.trigger("loadSuccess");
        },
        error     : function(){
          data.queries -= 1;
          if(data.queries == 0){
            $content.find(".js-row").detach();
            $this.fadeTo(data.searchFadeTime, 1.0, function(){
              $control.find(".js-reload").removeClass("loading");
            });
          }
          $this.trigger("loadError");
        }
      });
    },
    replaceContent : function(newContent){
      var $this = $(this);
      
      // replace the content
      $this.find(".js-tablewrapper").replaceWith(newContent);
      
      // rebind events to search input fields
      $this.find(".js-tablewrapper").find(".js-search input[type='text']").bind("change.fancygrid", function(){
        $(this).parents(".js-fancygrid").fancygrid('newSearch'); 
        return false;
      }).bind("focus.fancygrid", function(){
        $(this).select();
        return false;
      });
      
      $this.find("th.js-orderable").click(function(){
        $this.fancygrid("orderBy", $(this));
      });
    },                           
    nextPage : function(){
      var $this = $(this);
      data = $this.data('fancygrid');
      $this.fancygrid("setupPagination", data.query.pagination.page + 1, data.query.pagination.per_page);
      $this.fancygrid("search");
    },
    previousPage : function(){
      var $this = $(this);
      data = $this.data('fancygrid');
      $this.fancygrid("setupPagination", data.query.pagination.page - 1, data.query.pagination.per_page);
      $this.fancygrid("search");
    },
    perPage : function(perPage){
      var $this = $(this);
      data = $this.data('fancygrid');
      $this.fancygrid("setupPagination", 0, perPage);
      $this.fancygrid("search");
    },
    page : function(page){
      var $this = $(this);
      data = $this.data('fancygrid');
      $this.fancygrid("setupPagination", Number(page) - 1, data.query.pagination.per_page);
      $this.fancygrid("search");
    },
    reloadPage : function(){
      var $this = $(this);
      data = $this.data('fancygrid');
      $this.fancygrid("setupPagination", data.query.pagination.page, data.query.pagination.per_page);
      $this.fancygrid("setupConditions");
      $this.fancygrid("setupColumns");
      $this.fancygrid("setupOrder");
      $this.fancygrid("search");
    },
    newSearch : function(){
      var $this = $(this);
      data = $this.data('fancygrid');
      $this.fancygrid("setupPagination", 0, data.query.pagination.per_page);
      $this.fancygrid("setupConditions");
      $this.fancygrid("setupColumns");
      $this.fancygrid("setupOrder");
      $this.fancygrid("search");
    },
    clearSearch : function(){
      var $this = $(this);
      data = $this.data('fancygrid');
      
      // clear simple search
      $this.find(".js-attribute").each(function(){
        $(this).val("");
      });
      
      // clear complex search
      $this.find("ul.js-search-criteria li.js-search-criterion").detach();
      
      //$this.fancygrid("setupPagination", 0, data.query.pagination.per_page);
      $this.fancygrid("setupEmptyConditions");
      $this.fancygrid("search");
    },
    toggleSearch : function(){
      // toggle only the simple search
      $(this).find(".js-tablewrapper .js-search").toggle();
    },
    addCriterionRow : function(){
    	var $this = $(this);
    	var row = $($this.find(".js-search-template").html());
    	
    	// add criterion row
    	$this.find("ul.js-search-criteria").append(row);
    	
    	// button remove
    	row.find(".js-search-criterion-remove").click(function(){
    	  $(this).parents(".js-search-criterion").remove();
    	});
    	
      row.find("input[type='text']").bind("change.fancygrid", function(){
        $(this).parents(".js-fancygrid").fancygrid('newSearch'); 
        return false;
      }).bind("focus.fancygrid", function(){
        $(this).select();
        return false;
      });
    },
    showSortWindow : function(){
      var $this = $(this);
      
      $this.find(".js-sort-window").show();
      $this.find(".js-sort-content").show();
      
      $this.find(".js-sortable").sortable({
        connectWith: ".js-sortable",
        items: "li:not(.js-not-sortable)"
      })
    },
    closeSortWindow : function(){
      var $this = $(this);
      $this.find(".js-sort-window").hide();
      $this.find(".js-sort-content").hide();
      $this.fancygrid("reloadPage");
    },
    orderBy : function(column){
      $this = $(this);
      
      var old_order = column.attr("order");
      
      $this.find("th.js-orderable").removeAttr("order");
      
      if (old_order == "DESC"){
        column.attr("order", "ASC");
      } else {
        column.attr("order", "DESC");
      }

      $this.fancygrid("reloadPage");
    }
  };
})(jQuery);