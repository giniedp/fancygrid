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
          pagination      : { page : 0, per_page : 20 }, 
          conditions      : {},
          order           : {}
        },                
        searchFadeTime    : 250,
        searchFadeOpac    : 0.5,
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
            $this.find(".js-search").hide();
          }
          if (settings.hideTopControl){
            $this.find(".js-tablecontrol.top").hide();
          }
          if (settings.hideBottomControl){
            $this.find(".js-tablecontrol.bottom").hide();
          }
          
          // bind control buttons with functions
          
          // search attribute changed/focused
          $this.find(".js-attribute").bind("change.fancygrid", function(){
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
            $(this).parents(".js-fancygrid").fancygrid('toggleSearch', $(this).val()); 
            return false;
          });
          
        } else {
          // nothing to do when fancygrid is already initialized
          $.extend(data, options);
        }
      });
    },
    destroy : function(){
      return this.each(function(){
        var $this = $(this);
        data = $this.data('fancygrid');
        $this.unbind('.fancygrid');
        $this.removeData('fancygrid');
      });
    },
    setupConditions : function(){
      var $this = $(this);
      var data = $this.data('fancygrid');
      
      data.query.conditions = {};
      $(this).find(".js-attribute").each(function(){
        data.query.conditions[$(this).attr("name")] = $(this).val();
      });
    },
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
            $this.fancygrid("clearData");
            $this.fancygrid("attachData", $(result).find(".js-row"));
            
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
    clearData : function(){
      $(this).find(".js-row").detach();
    },
    attachData : function(toAttach){
      var $this = $(this);
      var $content = $this.find(".js-tablewrapper");
      var $control = $this.find(".js-tablecontrol");
      var $search = $this.find(".js-search");
      
      var data = $this.data('fancygrid');
      
      if(data.gridType == "table"){
        $content.find("table").append(toAttach);
      } else {
        $content.append(toAttach);
      }
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
      $this.fancygrid("search");
    },
    newSearch : function(){
      var $this = $(this);
      data = $this.data('fancygrid');
      $this.fancygrid("setupPagination", 0, data.query.pagination.per_page);
      $this.fancygrid("setupConditions");
      $this.fancygrid("search");
    },
    clearSearch : function(){
      var $this = $(this);
      data = $this.data('fancygrid');
      $this.find(".js-attribute").each(function(){
        $(this).val("");
      });
      $this.fancygrid("setupPagination", 0, data.query.pagination.per_page);
      $this.fancygrid("setupConditions");
      $this.fancygrid("search");
    },
    action : function(name, value){
      $(this).trigger("action_" + name, value);
    },
    toggleSearch : function(){
      $(this).find(".js-search").slideToggle();
    }
  };
})(jQuery);