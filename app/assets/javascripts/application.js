// This is a manifest file that'll be compiled into including all the files listed below.
// Add new JavaScript/Coffee code in separate files in this directory and they'll automatically
// be included in the compiled file accessible from http://example.com/assets/application.js
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
//= require jquery
//= require jquery_nested_form
//= require_tree .
//= require jquery.infinitescroll.min
//= require jquery_ujs

$(function() {
/* Convenience for forms or links that return HTML from a remote ajax call.
The returned markup will be inserted into the element id specified.
*/
	$('a[data-update-target]').on('ajax:success', function(evt, data) {
	var target = $(this).data('update-target');
		$('#' + target).html(data);
	});
	
	$('a[data-hide-target]').bind('ajax:success', function(evt, data) {
	var target = $(this).data('hide-target');
		$('#' + target).hide(data);
	});
	
	$.fn.enterKey = function (fnc) {
	    return this.each(function () {
	        $(this).keypress(function (ev) {
	            var keycode = (ev.keyCode ? ev.keyCode : ev.which);
	            if (keycode == '13') {
	                fnc.call(this, ev);
	            }
	        })
	    })
	}
	
	$(window).bind('beforeunload', function() {
	    var edition_mode = $("#edition_mode").length;
	    if(edition_mode > 0) {
	    	if($("#edition_mode").val() == "on" && confirmation_needed )
	        	return ' ';
	    }
	});
});

function init_masonry(container){
	$(container).imagesLoaded(function(){
		$(container).masonry({
		  itemSelector: '.extract_box:visible',
		  isFitWidth: true
		});
	});
	$(window).resize(function(){
		$(container).masonry({
		  itemSelector: '.extract_box:visible'
		});
	});

}

function getItemElement() {
  var elem = document.createElement('div');
  var wRand = Math.random();
  var hRand = Math.random();
  var widthClass = wRand > 0.92 ? 'w4' : wRand > 0.8 ? 'w3' : wRand > 0.6 ? 'w2' : '';
  var heightClass = hRand > 0.85 ? 'h4' : hRand > 0.6 ? 'h3' : hRand > 0.35 ? 'h2' : '';
  elem.className = 'item ' + widthClass + ' ' + heightClass;
  return elem;
}

function infinite_scroll_init(container_selector, element_selector, page_name, binder_name){
	
	var $container = $(container_selector);

    $container.imagesLoaded(function(){
    	$container.masonry({
		  itemSelector: element_selector + ":visible",
		  isFitWidth: true
		});
    	$(window).resize(function(){
			$container.masonry({
			  itemSelector: element_selector + ":visible",
			  isFitWidth: true
			});
		});
    });
    
    var locale= $("#locale").val();
    
    switch (locale){
	case 'en':
	  finished_message= 'No more pages to load.';
	  break;
	case 'gl':
	  finished_message= 'Non hai máis páxinas que cargar.';
	  break;
	case 'es':
	  finished_message= 'No hay más páginas que cargar.';
	  break;
	default:
	  finished_message= 'No more pages to load.';
	} 
    
    
    var $binder= eval("$("+ binder_name +")");
    $container.infinitescroll({
      navSelector  : '.pagination',    // selector for the paged navigation
      nextSelector : '.next a',  // selector for the NEXT link (to page 2)
      itemSelector : container_selector +' '+ element_selector,     // selector for all items you'll retrieve
      behavior: 'local',
  	  binder: $binder,
  	  //path: ["?" + page_name + "=",""],
      loading: {
      	  msgText: '',
          finishedMsg: finished_message,
          img: 'http://i.imgur.com/6RMhx.gif'
        }
      },
      // trigger Masonry as a callback
      function( newElements ) {
      	//console.log("masonry check1");
        // hide new items while they are loading
        var $newElems = $( newElements ).css({ opacity: 0 });
        // ensure that images load before adding to masonry layout
        $newElems.imagesLoaded(function(){
          // show elems now they're ready
			$newElems.animate({ opacity: 1 });
          	$container.masonry( 'appended', $newElems, true );
          	$container.masonry({isFitWidth: true});
        });
      }
    );
}

function popup_infinite_scroll_init(container_selector, element_selector, binder_name, element_class){
	var $container = $(container_selector);
	$container.masonry({
	  itemSelector: element_selector + ":visible"
	});
				
	$(window).resize(function(){
		$container.masonry({
		  itemSelector: element_selector + ":visible"
		});
	});
    
    var $binder= eval("$("+ binder_name +")");
    $binder.scroll(function(){
    	infinite_scrolling_detect($binder,element_class);
    });
}

function infinite_scrolling_detect($binder, element_class){
	element_list = $binder.find(".element_list");
	if($binder.scrollTop() > (element_list.innerHeight() - $binder.innerHeight() - 200)) {
		$binder.unbind('scroll');
		next_page= parseInt($binder.find('.next_page').val());
		last_page= parseInt($binder.find('.pages_total_number').val());		
		query_url= "/" + $("#locale").val() + "/selectors/paginate_elements";		
		if (next_page <= last_page){
			if ($binder.closest(".popup_content").find("#actions .search_form .current_user_input_container #display_bookmarks").size() > 0){
				jQuery.ajax({
			    	url: query_url,
					type: "GET",
					data: {"element_class": element_class, "page": next_page, "display_bookmarks": true}
			  	}).done(function(){
			  		$binder.scroll(function(){
				    	infinite_scrolling_detect($binder,element_class);
				    });
			  	});			
			}
			else {
		       	jQuery.ajax({
			    	url: query_url,
					type: "GET",
					data: {"element_class": element_class, "page": next_page}
			  	}).done(function(){
			  		$binder.scroll(function(){
				    	infinite_scrolling_detect($binder,element_class);
				    });
			  	});
		  	}
	  	}
   	}
}

function restart_popup_list(popup_id, element_class){
	$binder= $(popup_id + " .popup_body:first");
	$binder.scrollTop(0);
	$binder.unbind('scroll');
	$binder.scroll(function(){
    	infinite_scrolling_detect($binder,element_class);
    });
}

function all_users_popup_filter(button){
	var $button= $(button);
	if(! $button.hasClass('disabled')){
		$.each($button.closest("#actions").find(".my_activities_filter"), function(key, value){
			if($(value).hasClass('disabled')){
				$(value).toggleClass('disabled');
			}
		});	
		$button.toggleClass('disabled');	
		$button.closest("#actions").find(".search_form .current_user_input_container").html("");
		$button.closest("#actions").find(".search_form").submit();
	}
}

function current_user_popup_filter(button){
	var $button= $(button);
	if(! $button.hasClass('disabled')){
		$.each($button.closest("#actions").find(".my_activities_filter"), function(key, value){
			if($(value).hasClass('disabled')){
				$(value).toggleClass('disabled');
			}
		});	
		$button.toggleClass('disabled');			
		var $current_user_input = $button.closest("#actions").find(".current_user_input_copy_container");
		$button.closest("#actions").find(".search_form .current_user_input_container").html($current_user_input.html());
		$button.closest("#actions").find(".search_form").submit();
	}
}

function bookmarks_current_user_popup_filter(button){
	var $button= $(button);
	if(!$button.hasClass('disabled')){
		$.each($button.closest("#actions").find(".my_activities_filter"), function(key, value){
			if($(value).hasClass('disabled')){
				$(value).toggleClass('disabled');
			}
		});	
		$button.toggleClass('disabled');
		var $bookmarks_input = $button.closest("#actions").find(".bookmarks_input_copy_container");
		$button.closest("#actions").find(".search_form .current_user_input_container").html($bookmarks_input.html());
		$button.closest("#actions").find(".search_form").submit();			
	}
}

function add_elements_to_list(popup_id, refresh, element_class){
	var element_list = $(".area_popup" + popup_id + " .element_list");
	if (refresh){
		restart_popup_list(popup_id,element_class);
		element_list.html(elements_list);	
	}else{
		element_list.append(elements_list);
	}
	element_list.imagesLoaded(function(){
      element_list.masonry('reload');
    });
	$(".area_popup" + popup_id).find(".paginate_controls").html(paginate_controls);	
}

function open_area_popup(popup_id, path){
	if($(".area_popup"+popup_id).hasClass("selection")){
		var element_list = $(".area_popup" + popup_id + " .element_list");
		/*if (element_list.html() == "" || popup_id=="#element_assignment_selection"){*/
			var query_path= "/" + $("#locale").val() + path;
			jQuery.ajax({
		    	url: query_path,
				type: "GET"
		 }).done(function(){
		  		element_list.masonry('reload');
		  		$(popup_id + " .recommendations").masonry('reload');
		  		//Para el caso de seleccion multiple de usuarios en grupos que se actualicen con + y - los marcados previamente
		  		if (popup_id == "#group_user_selection")
		  			update_users_group_selected();
		  	});
		/*}*/
	}
	/*var top_position = $(window).height()*0.05 + $(document).scrollTop();
	$(".area_popup"+popup_id).css('top', top_position);*/
	$(".area_popup"+popup_id + "+ .area_popup_overlay").toggleClass("active");
	$(".area_popup"+popup_id).toggleClass("active");
	$("body").css('overflow', 'hidden');
	if($(".area_popup"+popup_id).hasClass("selection") && $(".area_popup"+popup_id).hasClass("simple")){
		$(".area_popup"+popup_id).find(".selected_elements").html("");	
	}
}

function close_area_popup(popup_id){
	close_comments();
	$(".area_popup"+popup_id + "+ .area_popup_overlay").removeClass("active");
	$(".area_popup"+popup_id).removeClass("active");
	$("body").css('overflow', 'auto');
	popup_go_back(popup_id);
}

function check_url(url){
	final_url = url;
	if (url.indexOf("http://") != 0){
		url_protocol= "http://";
		final_url= url_protocol + url;
	}
	return final_url;
}

function new_comment(form){
	var comments_div= $(form).closest(".comments");
	comments_div.html($(comments).html());
	comments_div.find(".new_comment .comment_input").autosize();
	var comments_count_container= comments_div.closest(".extract_box").find(".comments_counter");
	comments_count_container.html(comments_count);
	comments_div.find(".actual_comments").scrollTop(0);
	
	$('.new_comment').bind('ajax:success', function(){
  		new_comment(this);
	});	
}

function open_comments(comments_button){
	var active_element= $(comments_button).closest(".extract_box");
	active_element.find(".comment_input").autosize();
	$(comments_button).attr('onclick','close_comments();');
	if($(comments_button).parents(".area_popup").length){
		var overlay= $("#popup_overlay");
		var popup= $(comments_button).closest(".area_popup");
		popup.removeClass("visible_mode");
	}else{
		var overlay= $("#extract_box_overlay");
		var header= $("#header");
		var header_overlay= $("#header_overlay");
		header.toggleClass("active");
		header_overlay.toggleClass("active");	
	}
	active_element.toggleClass("active");
	active_element.find(".social_content").toggleClass("active");
	$(comments_button).closest(".icon_background").toggleClass("active");
	overlay.toggleClass("active");
}

function close_comments(){
	$(".area_popup.active").addClass("visible_mode");
	$(".extract_box.active").find(".social_icon.icon_comments").attr('onclick','open_comments(this);');
	$(".extract_box.active").removeClass("active");
	$("#header_overlay").removeClass("active");
	$("#header").removeClass("active");
	$("#extract_box_overlay").removeClass("active");
	$("#popup_overlay").removeClass("active");
	$(".social_content.active").removeClass("active");
	$(".icon_background.active").removeClass("active");
	
}

function open_area_slider(slider_id){
	$(".area_slider"+slider_id).css('width', '400px');
	//$("body").css('overflow', 'hidden');
	
}

function close_area_slider(slider_id){
	$(".area_slider"+slider_id).css('width', '0');
	//$("body").css('overflow', 'auto');
}

function enable_assignment(enable_assignment_button, requirement_type){
	requirement_row=$(enable_assignment_button).closest(".requirement_row");
	if($(".guide_container").index() != (-1) && $(".guide_container #edition_mode").val()== "on" && $(enable_assignment_button).closest(".area_popup").index() == (-1)){
		annotate_callback_location($(enable_assignment_button));
		switch(requirement_type){
		case "abstract_requirement":
		case "concrete_requirement":
			recommend_tools_call();
			$("#tool_assignment_selection .recommendations").html("<div class='loading'><img src='/images/icons/loader.gif' /></div>");
			$("#tool_assignment_selection .recommendations").masonry('reload');
			open_area_popup("#tool_assignment_selection",'/selectors/paginate_elements/?element_class=tool_assignment_selection');
		break;
		case "contributor_requirement":
		case "person_concrete_requirement":
			recommend_people_call();
			$("#person_assignment_selection .recommendations").html("<div class='loading'><img src='/images/icons/loader.gif' /></div>");
			$("#person_assignment_selection .recommendations").masonry('reload');		
			open_area_popup("#person_assignment_selection",'/selectors/paginate_elements/?element_class=person_assignment_selection');
		break;
		case "event_requirement":
		case "event_concrete_requirement":
			recommend_events_call();
			$("#event_assignment_selection .recommendations").html("<div class='loading'><img src='/images/icons/loader.gif' /></div>");
			$("#event_assignment_selection .recommendations").masonry('reload');		
			open_area_popup("#event_assignment_selection",'/selectors/paginate_elements/?element_class=event_assignment_selection');
		break;
		default:
		}
	}
}

function popup_show_element(element, element_id, element_path){
	close_comments();
	popup_id = "#" + $(".area_popup.active").attr('id');
	
	if (element_path != ""){
		jQuery.ajax({
	    	url: element_path,
			type: "GET",
			data: {"element_id" : element_id}
	  	}).done(function(result){
	  		$(popup_id + " .popup_details_content .popup_body").html(details);
	  		$(popup_id + " .popup_content").toggleClass("hidden");
	  		$(popup_id + " .popup_details_content").css('display', 'block');
	  		
	  		switch(element)
			{
			case "activity":
			  activity_form_init();
			  break;
			case "activity_sequence":
			  check_edition_mode(popup_id + " .popup_details_content .sequence_container");
			  activity_sequence_form_init();
			  break;
			case "technological_setting":
			  check_edition_mode(popup_id + " .popup_details_content .technological_setting_container");
			  break;
			case "contextual_setting":
			  check_edition_mode(popup_id + " .popup_details_content .contextual_setting_container");
			  popup_contextual_setting_form_init();
			  break;
			case "guide":
			  guide_form_init();
			  break;
			case "content":
				check_edition_mode(popup_id + " .popup_details_content .external_content_container");
				$(popup_id + " .popup_details_content .content_description textarea").autosize();
				break;
			case "event":				
				var latitude= $(details).find("#event_latitude").val();
				var longitude= $(details).find("#event_longitude").val();
				initialize_map(latitude,longitude);
				break;
			case "person":				
				var latitude= $(details).find("#person_latitude").val();
				var longitude= $(details).find("#person_longitude").val();
				initialize_map(latitude,longitude);
				break;
			case "site":				
					var latitude= $(details).find("#site_latitude").val();
					var longitude= $(details).find("#site_longitude").val();
					initialize_map(latitude,longitude);
					break;						
			default: 
			}
	  	});
  	}
}



function show_element_in_popup(element, element_id, element_path){
	close_comments();
	
	popup_id="#popup_show";
	
	/*var top_position = $(window).height()*0.05 + $(document).scrollTop();
	$(".area_popup"+popup_id).css('top', top_position);*/
	$(".area_popup"+popup_id + "+ .area_popup_overlay").toggleClass("active");
	$(".area_popup"+popup_id).toggleClass("active");
	$("body").css('overflow', 'hidden');
	
	
	if (element_path != ""){
		jQuery.ajax({
	    	url: element_path,	    	
			type: "GET",
			data: {"element_id" : element_id}						
	  	}).done(function(result){
	  		$(popup_id + " .popup_body").html(details);
	  		switch(element)
			{
				case "activity":				  
				  activity_form_init();
				  break;
				case "activity_sequence":
				  check_edition_mode(popup_id + " .popup_details_content .sequence_container");
				  activity_sequence_form_init();
				  break;
				case "technological_setting":
				  check_edition_mode(popup_id + " .popup_details_content .technological_setting_container");
				  break;
				case "contextual_setting":
				  check_edition_mode(popup_id + " .popup_details_content .contextual_setting_container");
				  popup_contextual_setting_form_init();
				  break;
				case "guide":
				  guide_form_init();
				  break;
				case "content":
					check_edition_mode(popup_id + " .popup_details_content .external_content_container");
					$(popup_id + " .popup_details_content .content_description textarea").autosize();
					break;
				case "event":				
					var latitude= $(details).find("#event_latitude").val();
					var longitude= $(details).find("#event_longitude").val();
					initialize_map(latitude,longitude);
					break;
				case "person":				
					var latitude= $(details).find("#person_latitude").val();
					var longitude= $(details).find("#person_longitude").val();
					initialize_map(latitude,longitude);
					break;
				case "site":				
					var latitude= $(details).find("#site_latitude").val();
					var longitude= $(details).find("#site_longitude").val();
					initialize_map(latitude,longitude);
					break;								
				default: 
			}
	  	});
  	}
}



function popup_go_back(popup_id){
	$(popup_id + " .popup_content").removeClass("hidden");
	$(popup_id + " .popup_details_content .popup_body").scrollTop(0);
	$(popup_id + " .popup_details_content .popup_body").html("");
	$(popup_id + " .popup_details_content").css('display', 'none');
}

function select_element(selection_button){
	var popup = $(selection_button).closest(".area_popup");
	var selected_elements = popup.find(".selected_elements");
	var extract_box = $(selection_button).closest(".extract_box");
	if (extract_box.length == 0){ 
		extract_box = $(selection_button).closest(".extract_box_fixed");
	}
	var selection_info= extract_box.find(".selection_info_box");
	selected_elements.append(selection_info.html());
	
	if(popup.hasClass("simple")){
		close_area_popup("#" + popup.attr("id"));
		eval(popup.find(".callback").val());
	}else{ //Multiple selection
		$(selection_button).toggleClass("active");
		var deselection_button= extract_box.find(".deselection_button");
		deselection_button.toggleClass("active");
		extract_box.css('opacity','0.7');
		eval(popup.find(".callback").val());
	}
}

function deselect_element(deselection_button){
	var popup = $(deselection_button).closest(".area_popup");
	var selected_elements = popup.find(".selected_elements");
	var deselected_element = popup.find(".deselected_element");
	var extract_box = $(deselection_button).closest(".extract_box");
	if (extract_box.length == 0){ 
		extract_box = $(deselection_button).closest(".extract_box_fixed");
	}
	var deselection_info = extract_box.find(".selection_info_box");
	var deselection_element_id = deselection_info.find(".element_id").val();
	var selection_button = extract_box.find(".selection_button");
	selection_button.toggleClass("active");
	$(deselection_button).toggleClass("active");
	extract_box.css('opacity','1');
	deselected_element.html(deselection_info.html());
	selected_elements.find(".element_id[value="+deselection_element_id+"]").closest(".selection_info").remove();
	eval(popup.find(".deselect_callback").val());
}

function check_edition_mode(element){
	if($(element + " #edition_mode").val()== "off"){
		disable_edition(element);
	}
	if($(element + " #template_edition_mode").val()== "off"){
		disable_template_edition(element);
	}
};

function disable_edition(element){
	$(element + " .has_edition_controls").removeClass("active");
	$(element + " .editable").removeClass("active");
	$(element + " .editable input").attr('readonly','readonly');
	$(element +  " .editable textarea").attr('readonly','readonly');
	$(element + " .adapter_box1").css("display","none");
	$(element + " .add_device_box").css("display","none");
	$(element + " .add_application_box").css("display","none");
	$(element + " .form_actions").css("display","none");
	$(element + " .select_resource_button").removeClass("cboxElement");
	$(element + " #user_avatar").css("display","none");
	$(element + " .add_contribution").removeClass("active");
	$(element + " .change_profile_avatar").removeClass("active");
	$(element + " .slider").attr( "disabled", "disabled");
	
};

function disable_template_edition(element){
	$(element + " .template_editable").removeClass("active");
	$(element + " .template_editable input").attr('readonly','readonly');
	$(element +  " .template_editable textarea").attr('readonly','readonly');
};

function enable_edition(element){
	$(element + " .has_edition_controls").toggleClass("active");
	$(element + " .editable").toggleClass("active");
	$(element + " .editable input").removeAttr('readonly');
	$(element + " .editable textarea").removeAttr('readonly');
	$(element + " .adapter_box1").css("display","block");
	$(element + " .add_device_box").css("display","table");
	$(element + " .add_application_box").css("display","table");
	$(element + " .form_actions").css("display","block");
	$(element + " #user_avatar").css("display","block");
	$(element + " .select_resource_button").addClass("cboxElement");
	$(".popup_open_button").colorbox({inline:true, width:"70%", height: "90%",onClosed: function(){close_selector_popup($(this).attr("href"))}});
};

function view_details(element,element_id){
	jQuery.ajax({
    	url: "show_"+element,
		type: "GET",
		data: {"id" : element_id}
  	}).done(function(result){
  		$("#"+ element +"_selector_box .details").html(details);
  		$("#"+ element +"_selector_box #list_title").toggleClass("hidden");
  		$("#"+ element +"_selector_box #individual_title").toggleClass("hidden");
  		$("#"+ element +"_selector_box .selector_actions").toggleClass("hidden");
  		$("#"+ element +"_selector_box .selector").toggleClass("hidden");
  		$("#"+ element +"_selector_box .details").toggleClass("hidden");
  		check_edition_mode("."+element+"_details");
  		$("." + element+ "_details textarea").autosize();
  		if(element=="sequence"){
  			$(".sequence_details .actions_controls_bar").css("display","none");
  		}
  	});
};

function back_to_list_selectable(selector_box){	
	$(selector_box +" #list_title").toggleClass("hidden");
	$(selector_box +" #individual_title").toggleClass("hidden");
	$(selector_box +" .selector_actions").toggleClass("hidden");
  	$(selector_box +" .details").toggleClass("hidden");
  	$(selector_box +" .selector").toggleClass("hidden");
  	if(selector_box == "#device_selector_box" || selector_box == "#application_selector_box" || selector_box == "#abstract_requirement_assignment_box" || selector_box == "#tool_selector_box"){
  		$(selector_box +" .details_iframe").attr('src','');
  	}
}

function close_selector_popup(box){
	$(box +" #list_title").removeClass("hidden");
	$(box +" #individual_title").addClass("hidden");
	$(box +" .selector_actions").addClass("hidden");
  	$(box +" .details").addClass("hidden");
  	$(box +" .selector").removeClass("hidden");
}

function tool_details(tool_id, button){
	tool_selector_box= $(button).closest(".tool_selector_box");
	container= $(button).closest("#cboxLoadedContent");
  	container_height= container.height();
  	container_height= container_height-container_height * 0.22;
  	container_width= tool_selector_box.width();
  	details_iframe= tool_selector_box.find(".details_iframe");
  	details_iframe.attr("src",tool_id);
  	details_iframe.attr("height",container_height);
  	details_iframe.attr("width",container_width);
  	
  	
  	tool_selector_box.find("#list_title").toggleClass("hidden");
	tool_selector_box.find("#individual_title").toggleClass("hidden");
	tool_selector_box.find(".selector_actions").toggleClass("hidden");
	tool_selector_box.find(".selector").toggleClass("hidden");
	tool_selector_box.find(".details").toggleClass("hidden");
}

function tool_details_view(tool_id, button){
	tool_selector_box= $("#tool_view_box");
  	container_height= $("#pagewrap").height() * 0.6;
  	container_width= $("#pagewrap").width() * 0.9;
  	details_iframe= tool_selector_box.find(".details_iframe");
  	details_iframe.attr("src",tool_id);
  	details_iframe.attr("height",container_height);
  	details_iframe.attr("width",container_width);
}

function Expand(obj){
 if (!obj.savesize) obj.savesize=obj.size;
 obj.size=Math.max(obj.savesize,obj.value.length-7);

}

function add_item_to_itemize(add_button){
	item_li = $("#elements_library #item_to_itemize").html();
	$(add_button).closest(".component_container").find("ul").append(item_li);
	$(add_button).closest(".component_container").find("textarea").autosize();	
}

function delete_text_container(delete_button){
	text_id = $(delete_button).closest(".text_container").find("#text_id").val();
	if ( text_id != ""){
		$(delete_button).closest(".text_container").css('display','none');
		$(delete_button).closest(".text_container").addClass('deleted');
	}else{
		$(delete_button).closest(".text_container").remove();
	}
}

function change_picture(change_button){
	var picture= $(change_button).closest(".picture_container");
	picture.find(".file_upload #area_image").click();
}

function select_element_picture(change_button){
	var description_container= $(change_button).closest(".description_container");
	description_container.find(".file_upload .input_element_image").click();
}


function select_element_image_new(change_button){
	var description_container= $(change_button).closest(".picture_container");
	description_container.find(".file_upload .input_element_image").click();
}


function handleFileSelect(picture_input, evt) {
    var files = evt.target.files; // FileList object
    var picture_preview = $(picture_input).closest(".picture_container").find(".image_preview");
	// Loop through the FileList and render image files as thumbnails.
	for (var i = 0, f; f = files[i]; i++) {
	  // Only process image files.
	  if (!f.type.match('image.*')) {
	    continue;
	  }
	  var reader = new FileReader();
	  // Closure to capture the file information.
	  reader.onload = (function(theFile) {
	    return function(e) {
	     	picture_preview.attr('src',e.target.result);
	    };
	  })(f);
	  // Read in the image file as a data URL.
	  reader.readAsDataURL(f);
	}
}

function image_preview(element_image_input, evt) {
	var files = evt.target.files; // FileList object
    var picture_preview = $(element_image_input).closest(".picture_container").find(".image_preview");
    var description_container= $(element_image_input).closest(".description_container").find(".description");
    description_container.addClass("description_right");
    textarea_height= description_container.find("textarea");
    new_height= textarea_height[0].scrollHeight;
    description_container.find("textarea").height(new_height);
	// Loop through the FileList and render image files as thumbnails.
	for (var i = 0, f; f = files[i]; i++) {
	  // Only process image files.
	  if (!f.type.match('image.*')) {
	    continue;
	  }
	  var reader = new FileReader();
	  // Closure to capture the file information.
	  reader.onload = (function(theFile) {
	    return function(e) {
	     	picture_preview.attr('src',e.target.result);
	    };
	  })(f);
	  // Read in the image file as a data URL.
	  reader.readAsDataURL(f);
	}
}

function image_preview_new(element_image_input, evt) {
	var files = evt.target.files; // FileList object
    var picture_preview = $(element_image_input).closest(".picture_container").find(".image_preview");

	for (var i = 0, f; f = files[i]; i++) {
	  // Only process image files.
	  if (!f.type.match('image.*')) {
	    continue;
	  }
	  var reader = new FileReader();
	  // Closure to capture the file information.
	  reader.onload = (function(theFile) {
	    return function(e) {
	     	picture_preview.attr('src',e.target.result);
	    };
	  })(f);
	  // Read in the image file as a data URL.
	  reader.readAsDataURL(f);
	}
}

function close_filters(button){
	$(".filters").css('height','0');
	$("#content_index").css('top', '0px');
	$(".footer").css('top', '0px');
	$(".toggle_filters").attr('onclick', 'show_filters(this)');
}

function show_filters(button){
	$(".filters").css('height','115px');
	$("#content_index").css('top', '115px');
	$(".footer").css('top', '115px');
	$(".toggle_filters").attr('onclick', 'close_filters(this)');
}


function assign_owner(owner_type, owner_id, owner_name, current_tab, image_url) {
	$(".name_ownership_group").html(owner_name);

	var ownership_group_class = "ownership_group_" + current_tab;

	$("."+ownership_group_class+" .selection_info_box .selection_info").find(".element_id").val(owner_id);
	$("."+ownership_group_class+" .selection_info_box .selection_info").find(".element_id").attr("name", current_tab + "[owner_id]");
	
	$("."+ownership_group_class+" .selection_info_box .selection_info").find(".element_class").val(owner_type);
	$("."+ownership_group_class+" .selection_info_box .selection_info").find(".element_class").attr("name", current_tab + "[owner_type]");
	toggle_dropdown_owner_options();
	$("."+ownership_group_class+" .image_ownership_group img").attr('src', image_url);
}

function toggle_dropdown_owner_options() {
	$(".ownership_box ul").toggleClass("visible");
}

function toggle_dropbox_list_visibility(button) {
	$(button).closest(".dropdown").find(".dropdown_list").toggleClass("visible");
}

function hide_dropdown_list(button) {
	$(button).find(".dropdown_list").removeClass("visible");
}

function toggle_advanced_search_visibility(button) {
	$(".advanced_search").toggleClass("visible");
	if ($(".advanced_search").hasClass("visible")){
		$(button).closest("li").css("background-color", "#1887E3");
		if ($("#map-canvas").size() > 0 )
			google.maps.event.trigger(map, "resize");
	}
	else
		$(button).closest("li").css("background-color", "#534A5F");
}

function toggle_full_hamburger(button) {
	if ($(".full_hamburger").css("width") == "0px")
		$('.full_hamburger').css('width', '94px');
	else
		$('.full_hamburger').css('width', '0px');
}

function toggle_full_me_and_circumstance(button) {
	$(button).closest(".dropdown").find(".full_me_and_circumstance").toggleClass("visible");
}

function hide_full_me_and_circumstance(button) {
	$(button).find(".full_me_and_circumstance").removeClass("visible");
}

function remove_popup_body(){
	$("#popups").find(".popup_body").empty();
}

function change_element_bookmark_state (button){	
	element_id=$(button).closest(".extract_box").find(".selection_info_box .selection_info .element_id").val();
	element_class=$(button).closest(".extract_box").find(".selection_info_box .selection_info .element_class").val();
	if ($(button).hasClass("add_bookmark")){
		url="../bookmarks/add_bookmark";
	}
	else if ($(button).hasClass("bookmarked")){
		url="../bookmarks/remove_bookmark";
	}
	
	$(button).toggleClass("bookmarked");
	$(button).toggleClass("add_bookmark");
	
	jQuery.ajax({
    	url: url,
		type: "GET",
		data: {"element_class": element_class, "element_id": element_id}
	}).done(function() {
		
	});

}

function change_element_bookmark_state_in_extract_fixed (button){	
	element_id=$(button).closest(".extract_box_fixed").find(".selection_info_box .selection_info .element_id").val();
	element_class=$(button).closest(".extract_box_fixed").find(".selection_info_box .selection_info .element_class").val();
	if ($(button).hasClass("add_bookmark")){
		url="../bookmarks/add_bookmark";
	}
	else if ($(button).hasClass("bookmarked")){
		url="../bookmarks/remove_bookmark";
	}
	
	$(button).toggleClass("bookmarked");
	$(button).toggleClass("add_bookmark");
	
	jQuery.ajax({
    	url: url,
		type: "GET",
		data: {"element_class": element_class, "element_id": element_id}
	}).done(function() {
		
	});

}

function change_element_bookmark_state_in_excerpt (button){	
	element_id=$(button).closest(".excerpt").find(".selection_info_box .selection_info .element_id").val();
	element_class=$(button).closest(".excerpt").find(".selection_info_box .selection_info .element_class").val();
	if ($(button).hasClass("add_bookmark")){
		url= "/" + $("#locale").val() + "/bookmarks/add_bookmark";
	}
	else if ($(button).hasClass("bookmarked")){
		url= "/" + $("#locale").val() + "/bookmarks/remove_bookmark";		
	}
	
	$(button).toggleClass("bookmarked");
	$(button).toggleClass("add_bookmark");
	
	jQuery.ajax({
    	url: url,
		type: "GET",
		data: {"element_class": element_class, "element_id": element_id}
	}).done(function() {
		
	});

}

function change_element_bookmark_state_in_show (button,element_class,element_id){			
	if ($(button).hasClass("add_bookmark")){
		url="../bookmarks/add_bookmark";
	}
	else if ($(button).hasClass("bookmarked")){
		url="../bookmarks/remove_bookmark";
	}
	
	$(button).toggleClass("bookmarked");
	$(button).toggleClass("add_bookmark");
	
	jQuery.ajax({
    	url: url,
		type: "GET",
		data: {"element_class": element_class, "element_id": element_id}
	}).done(function() {
		
	});

}



function remove_bookmarked_element (button,element_id,element_class){	
	url="../bookmarks/remove_bookmark";	
	jQuery.ajax({
    	url: url,
		type: "GET",
		data: {"element_class": element_class, "element_id": element_id}
	}).done(function() {
		
	});
	if (element_class=="application") {
		number=parseInt($(button).closest(".bookmarked_applications").find("span.number").text());
		$(button).closest(".bookmarked_applications").find("span.number").html(number-1);
	}
	else if (element_class=="event") {
		number=parseInt($(button).closest(".bookmarked_events").find("span.number").text());
		$(button).closest(".bookmarked_events").find("span.number").html(number-1);
	}	
	else if (element_class=="person") {
		number=parseInt($(button).closest(".bookmarked_people").find("span.number").text());
		$(button).closest(".bookmarked_people").find("span.number").html(number-1);
	}
	else if (element_class=="lecture") {
		number=parseInt($(button).closest(".bookmarked_lectures").find("span.number").text());
		$(button).closest(".bookmarked_lectures").find("span.number").html(number-1);
	}
	else if (element_class=="site") {
		number=parseInt($(button).closest(".bookmarked_sites").find("span.number").text());
		$(button).closest(".bookmarked_sites").find("span.number").html(number-1);
	}	
	else if (element_class=="documentary") {
		number=parseInt($(button).closest(".bookmarked_documentaries").find("span.number").text());
		$(button).closest(".bookmarked_documentaries").find("span.number").html(number-1);
	}
	else if (element_class=="course") {
		number=parseInt($(button).closest(".bookmarked_courses").find("span.number").text());
		$(button).closest(".bookmarked_courses").find("span.number").html(number-1);
	}
	else if (element_class=="article") {
		number=parseInt($(button).closest(".bookmarked_articles").find("span.number").text());
		$(button).closest(".bookmarked_articles").find("span.number").html(number-1);
	}
	else if (element_class=="lre") {
		number=parseInt($(button).closest(".bookmarked_lres").find("span.number").text());
		$(button).closest(".bookmarked_lres").find("span.number").html(number-1);
	}
	else if (element_class=="post") {
		number=parseInt($(button).closest(".bookmarked_posts").find("span.number").text());
		$(button).closest(".bookmarked_posts").find("span.number").html(number-1);
	}
	else if (element_class=="slideshow") {
		number=parseInt($(button).closest(".bookmarked_slideshows").find("span.number").text());
		$(button).closest(".bookmarked_slideshows").find("span.number").html(number-1);
	}
	else if (element_class=="biography") {
		number=parseInt($(button).closest(".bookmarked_biographies").find("span.number").text());
		$(button).closest(".bookmarked_biographies").find("span.number").html(number-1);
	}
	else if (element_class=="report") {
		number=parseInt($(button).closest(".bookmarked_reports").find("span.number").text());
		$(button).closest(".bookmarked_reports").find("span.number").html(number-1);
	}
	else if (element_class=="widget") {
		number=parseInt($(button).closest(".bookmarked_widgets").find("span.number").text());
		$(button).closest(".bookmarked_widgets").find("span.number").html(number-1);
	}
	else if (element_class=="klascement") {
		number=parseInt($(button).closest(".bookmarked_klascements").find("span.number").text());
		$(button).closest(".bookmarked_klascements").find("span.number").html(number-1);
	}
	else if (element_class=="artwork") {
		number=parseInt($(button).closest(".bookmarked_artworks").find("span.number").text());
		$(button).closest(".bookmarked_artworks").find("span.number").html(number-1);
	}
	else if (element_class=="book") {
		number=parseInt($(button).closest(".bookmarked_books").find("span.number").text());
		$(button).closest(".bookmarked_books").find("span.number").html(number-1);
	}																																		
	$(button).closest(".bookmarked_box").remove();	
}	


function toggle_home_discover_create(button){
	if (!$(button).hasClass("active")){	
		$(".discover_row").toggleClass("active");
		$(".create_row").toggleClass("active");
		if ($(".discover_row").hasClass("active")){
			$(".mini_extract.mini_extract_create").hide();
			$(".mini_extract.mini_extract_discover").show();
		}
		else {
			$(".mini_extract.mini_extract_discover").hide();
			$(".mini_extract.mini_extract_create").show();
		}
	}
}


function toogle_wikipedia_properties_height(button) {
	if ($(button).hasClass("short_info")){
		$(button).addClass('long_info').removeClass('short_info');
		$(button).closest(".wikipedia_properties").addClass('long_info').removeClass('short_info');
			
	}
	else if ($(button).hasClass("long_info")){
		$(button).addClass('short_info').removeClass('long_info');	
		$(button).closest(".wikipedia_properties").addClass('short_info').removeClass('long_info');
	}
}
