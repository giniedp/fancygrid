(function( $ ) {
  var Fancygrid = window.Fancygrid = {};

	var FancygridWrapper = function(name, container, data){
		this.name = name;
		this.container = container;
		this.data = data;
		
		this.components = {};
		this.components.search = container.find(".fg-search");
		this.components.controls = container.find(".fg-control-bar");
	};

	FancygridWrapper.prototype.reload = function(count){
		
	};
		
	FancygridWrapper.prototype.flipPage = function(count){
		this.flipToPage(this.data.pagination.page + count);
	};
	
	FancygridWrapper.prototype.flipToPage = function(count){
		this.data.pagination.page = Math.max(1, count);
	};
	
	FancygridWrapper.prototype.setPerPage = function(count){
		count = Math.max(1, count);
		this.data.pagination.per_page = count;
		if (this.components.per_page){
			this.components.per_page.val(count).text(count);
		}
	};
	
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
        ajaxUrl        : "/", 
				ajaxType       : "GET",
        name           : "",
        searchFadeTime : 25,
        searchFadeOpac : 0.5,
        queries        : 0,
        query: { 
          pagination: { 
            page     : (options.page || 1), 
            per_page : (options.perPage || 25)
          },
          columns    : [], 
          conditions : [],
          operator   : "any",
          order      : {}
        },
      };
      options = (options || {});
      $.extend(settings, options);
      
      return this.each(function(){
        var $this = $(this);
        var data = $this.data('fancygrid');
        
        if (!data){
          // initialize fancygrid
          
          // set data
          $this.data('fancygrid', settings);
          
          // Hide the helper stuff
          $(".fg-sort-window, .fg-sort-content, .fg-search-template").hide();
          
          // hide search tab and controls if wanted
          if (!settings.searchVisible){
            $this.find(".fg-search").hide();
          } else {
            settings.searchVisible = true;
          }
          
          // bind control buttons with functions
          
          // search attribute changed/focused
          $this.find(".fg-search").find("input[type='text'], select").bind("change.fancygrid", function(){
            $(this).parents(".fg-container").fancygrid('newSearch'); 
          }).bind("focus.fancygrid", function(){
            $(this).select();
          });
          
          // search attribute changed/focused
          $this.find(".fg-page").bind("change.fancygrid", function(){
            $(this).parents(".fg-container").fancygrid('page', $(this).val()); 
          }).bind("focus.fancygrid", function(){
            $(this).select();
          });
          
          // previous page click
          $this.find(".fg-previous").bind("click.fancygrid", function(e){
						e.preventDefault();
            $(this).parents(".fg-container").fancygrid('previousPage'); 
          });
          
          // next page click
          $this.find(".fg-next").bind("click.fancygrid", function(e){
						e.preventDefault();
            $(this).parents(".fg-container").fancygrid('nextPage'); 
          });
          
          // reload click
          $this.find(".fg-reload").bind("click.fancygrid", function(e){
						e.preventDefault();
            $(this).parents(".fg-container").fancygrid('reloadPage'); 
          });
          
          // clear click
          $this.find(".fg-clear").bind("click.fancygrid", function(e){
						e.preventDefault();
            $(this).parents(".fg-container").fancygrid('clearSearch'); 
          });
          
          // per page change
          $this.find(".fg-per-page").bind("change.fancygrid", function(e){
						e.preventDefault();
            $(this).parents(".fg-container").fancygrid('perPage', $(this).val()); 
          });
          
          // magnifier click
          $this.find(".fg-magnify").bind("click.fancygrid", function(e){
						e.preventDefault();
            $(this).parents(".fg-container").fancygrid('toggleSearch'); 
          });
          
          // sort click
          $this.find(".fg-sort").bind("click.fancygrid", function(e){
						e.preventDefault();
            $(this).parents(".fg-container").fancygrid('toggleSort'); 
          });
          
          //extended search submit
          $this.find(".fg-search-submit").bind("click.fancygrid", function(e){
						e.preventDefault();
            $(this).parents(".fg-container").fancygrid('newSearch'); 
          });
          
          //button remove
          $this.find(".fg-search-remove").click(function(e){
						e.preventDefault();
            $(this).parents(".fg-search-criterion").remove();
          });
          
          //button add new criterion
          $this.find(".fg-search-add").click(function(e){
						e.preventDefault();
            $(this).fancygrid("addCriterionRow");
          });
          
					Fancygrid[data.name] = new FancygridInstance(data.name, $this, data);
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
      
      data = $this.data('fancygrid');
      data.query.conditions = [];
      data.query.operator = $this.find("#fg-search-conditions:checked").val() || "any";
      
      $this.find(".fg-search-criterion").each(function(){
        var column = $(this).find("select[name='column']").val();
        var operator  = $(this).find("select[name='operator']").val();
        var value = $(this).find("input[name='leaf_value']").val();
        
        if (typeof(data.query.conditions[leaf_name]) === "undefined"){
          data.query.conditions[leaf_name] = [];
        }
        
        data.query.conditions[leaf_name].push({
					table    : "",
					column   : column,
          operator : operator,
          value    : value
        });
      }); 
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
      var leaf = $this.find("th.fg-orderable[order='ASC'], th.fg-orderable[order='DESC']");
      
      if (leaf.length > 0){
        order.table = leaf.attr("table");
        order.leaf = leaf.attr("leaf");
        order.direction = leaf.attr("order");        
      }

      data.query.order = order;
    },
    //
    // Fills the fancygrid query data with leaf order and leaf visibility conditions
    //
    setupColumns : function(){
      var $this = $(this);
      var data = $this.data('fancygrid');
      var leafs = {};
      
      var visibleArray = $this.find('.fg-sortable-visible li:not(.fg-not-sortable)');
      var hiddenArray = $this.find('.fg-sortable-hidden li:not(.fg-not-sortable)');
      
      var index = 0;
      $(visibleArray).each(function(){
        leafs[$(this).attr("id")] = {
          visible : true,
          position : index
        };
        index += 1;
      });
      $(hiddenArray).each(function(){
        leafs[$(this).attr("id")] = {
          visible : false,
          position : index
        };
        index += 1;
      });
      
      data.query.leafs = leafs;
    },
    order : function(){
      return "";
    },
    search : function(){
      var $this = $(this);
      var $content = $this.find(".fg-tablewrapper");
      var $control = $this.find(".fg-control-bar");
      var data = $this.data('fancygrid');
      data.queries += 1;
      data.query.search_visible = $this.find(".fg-search").is(":visible");
      
      $control.find(".fg-reload").addClass("loading");
      $this.fadeTo(data.searchFadeTime, data.searchFadeOpac);
      
      queryData = { "fancygrid" : {} };
      queryData.fancygrid[data.name] = data.query;
      
      $.ajax({
        type      : data.ajaxType,
        url       : data.ajaxUrl,
        data      : queryData,
        dataType  : "html",
        success   : function(result){  
          data.queries -= 1;
          if(data.queries === 0){
            $this.fancygrid("replaceContent", $(result).find(".fg-tablewrapper"));
            
            $control.find(".fg-per-page").val(data.query.pagination.per_page);
            $control.find(".fg-page").val(Number(data.query.pagination.page) + 1);
            
            total = (Number($(result).find(".fg-result-total").html()));
            totalPages = total / data.query.pagination.per_page;
            totalPages = (totalPages | 0) + 1;

            $control.find(".fg-page-total").text(totalPages);
            $control.find(".fg-result-total").html(total);
            
            $this.fadeTo(data.searchFadeTime, 1.0, function(){
              $control.find(".fg-reload").removeClass("loading");
            }); 
          }
          $this.trigger("loadSuccess");
        },
        error     : function(){
          data.queries -= 1;
          if(data.queries === 0){
            $content.find(".fg-row").detach();
            $this.fadeTo(data.searchFadeTime, 1.0, function(){
              $control.find(".fg-reload").removeClass("loading");
            });
          }
          $this.trigger("loadError");
        }
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
      $this.find(".fg-attribute").each(function(){
        $(this).val("");
      });
      
      // clear complex search
      $this.find("ul.fg-search-criteria li.fg-search-criterion").detach();
      
      //$this.fancygrid("setupPagination", 0, data.query.pagination.per_page);
      $this.fancygrid("setupEmptyConditions");
      $this.fancygrid("search");
    },
    toggleSearch : function(){
      var $this = $(this);
      data = $this.data('fancygrid');
      
      // toggle only the simple search
      $this.find(".fg-search").toggle();
      data.searchVisible = $this.find(".fg-search").is(":visible");
    },
    addCriterionRow : function(){
      var $this = $(this);
      var row = $($this.find(".fg-search-template").html());
      
      // add criterion row
      $this.find("ul.fg-search-criteria").append(row);
      
      // button remove
      row.find(".fg-search-remove").click(function(){
        $(this).parents(".fg-search-criterion").remove();
      });
      
      row.find("input[type='text']").bind("change.fancygrid", function(){
        $(this).parents(".fg-container").fancygrid('newSearch'); 
        return false;
      }).bind("focus.fancygrid", function(){
        $(this).select();
        return false;
      });
    },
    showSortWindow : function(){
      var $this = $(this);
      
      $this.find(".fg-sort-window").show();
      $this.find(".fg-sort-content").show();
      
      $this.find(".fg-sortable").sortable({
        connectWith: ".fg-sortable",
        items: "li:not(.fg-not-sortable)"
      });
    },
    closeSortWindow : function(){
      var $this = $(this);
      $this.find(".fg-sort-window").hide();
      $this.find(".fg-sort-content").hide();
      $this.fancygrid("reloadPage");
    },
    orderBy : function(leaf){
      $this = $(this);
      
      var old_order = leaf.attr("order");
      
      $this.find("th.fg-orderable").removeAttr("order");
      
      if (old_order === "DESC"){
        leaf.attr("order", "ASC");
      } else {
        leaf.attr("order", "DESC");
      }

      $this.fancygrid("reloadPage");
    }
  };
})(jQuery);