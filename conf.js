$(function() {
	var person_array;
	var schedule_array;
	var countries_json_array;
	var topics_array;
	var topics2_array;
	var roles = ['?', 'выступоўца', 'старшыня', 'мадэратар'];
	var events = ['?', 'тэматычны блок', 'пасяджэнне', 'даклад', 'круглы стол'];
	var colors = ['lightyellow', 'lightgreen', 'pink'];
	var bcolors = ['black', '#33CCCC', '#FFFF66', '#FF9933', '#CC0099', '#CC0000', '#996666', '#99FF33', '#CCCC99', 'gray'];
	function format(item) { return item.here_name; };
	function format2(item) { return item.be; };
	function add_sch_row (item, table, cid){
		// alert(cid);
		if (item.person_id == cid){
			var this_event; // = topics_array[item.event_id];
			$.each( topics_array, function( index, thing ) {
					if (thing.id == item.event_id) {
							this_event = thing;
							return;
					}
				});
			var row =$('<tr></tr>');
			var topic = (this_event.be == 'NOTOPIC'? '<i>(няма тэмы альбо ўдзел без дакладу)</i>' : this_event.be);
			$('<td><div class=ellipsis>' + events[this_event.event_type] + ' '+ item.event_id + ' <i>'+ 	topic +'</i></div></td>').appendTo(row); 
			$('<td>' + this_event.event_date + '-га, '+ this_event.event_start + ', аўдыторыя ' + this_event.event_place +'</td>').appendTo(row); 
			$('<td>' + roles[item.person_role]  + '</td>').appendTo(row); 
			row.appendTo(table);
			// console.log(item.here_name);
			// console.log(item.person_id);
		}
		// console.log(item.person_id);
	}
	function add_sch_row2 (item, table, cid){
		// alert(cid);
		if (item.person_id == cid){
			var this_event; // = topics_array[item.event_id];
			$.each( topics_array, function( index, thing ) {
					if (thing.id == item.event_id) {
							this_event = thing;
							return;
					}
				});
			var topic = (this_event.be == 'NOTOPIC'? '<i>(няма тэмы альбо ўдзел без дакладу)</i>' : this_event.be);
			var str = '<div style="border-bottom:2x solid black;">' + events[this_event.event_type] + ' '+ item.event_id + ' <i>'+ 	topic +'</i></div>' + '<div>' + this_event.event_date + '-га, '+ this_event.event_start + ', аўдыторыя ' + this_event.event_place +'</div>'+ '<div>' + roles[item.person_role]  + '</div><hr/>';
			// console.log(str);
			table.append(str);
			// console.log(item.person_id);
		}
		// console.log(item.person_id);
	}
	function person_info(cid) {
		var linksgrid = $('#myTable');
		linksgrid.children().remove();
		$('<thead id=myTableHead></thead>').appendTo(linksgrid); 
		var mth = $('#myTableHead');
		$('<tr id=headrow></tr>').appendTo(mth); 
			var headrow = $('#headrow');
			$('<th width=100>Падзея</th>').appendTo(headrow); 
			$('<th width=100>Час</th>').appendTo(headrow); 
			$('<th width=100>Дзейнасць</th>').appendTo(headrow); 
		$('<tbody id=tableBody>qw</tbody>').appendTo(linksgrid); 
		var tableBody = $('#tableBody');
		// console.log('!');
		// alert(cid);
		// console.log('!');
		jQuery.each(schedule_array, function() { add_sch_row(this, tableBody, cid); });
	}
	function person_popup(pid, name) {
		$('#person-name').text(name);
		$('#person-country').text(pid);
		var this_person_info = $('#this-person-info');
		this_person_info.text('');
		jQuery.each(schedule_array, function() { add_sch_row2(this, this_person_info, pid); });
		$('#signup').fadeIn("slow");
	}
	var lvl_pre = 0;
	function add_def_row (item, table, cid){
		// alert(cid);
		if (item.event_type == 3){
			// var this_event = topics_array[item.event_id];
			var row =$('<tr></tr>');
			if (lvl_pre > item.lvl){
				$('<td colspan = "6">&nbsp;</td>').appendTo(row);  // name
				row.appendTo(table);
				row =$('<tr></tr>');
			}
			$('<td style="background-color:' + colors[item.event_date-22]+';">' + item.event_date  + '</td>').appendTo(row);  // day
			lvl_pre = item.lvl;
			var person_cell = '';
			$.each( schedule_array, function( key, value ) {
				if (value.event_id == item.id) {
				$.each( person_array, function( skey, svalue ) {
					if (svalue.id == value.person_id) {
						person_cell += '<div>' + '<img src="blank.gif" class="flag flag-' + svalue.code + '" title="' + svalue.country + '">'+ '<span style="padding-left:3px;">' +
						'<a id=person-'+ svalue.id +' class=person name=signup href=#'+skey+'>' +
						svalue.aname + ' '  + svalue.bname + 
						'</a>' +
						'</span></div>';
					}
				});
				}
			});
			$('<td style="background-color:' + bcolors[item.lvl] + ';">' + item.event_start + '—' + item.event_end  + ' (' + item.lvl +')</td>').appendTo(row);  // time
			$('<td>аўдыторыя ' + item.event_place  + '</td>').appendTo(row);  // place
			var area = item.parent_id;
			var area_title;
			$.each( topics_array, function( index, thing ) {
					if (thing.id == area) {
							area_title = thing.be;
							return;
					}
				});
			var title = area_title ? ('title="' + area_title + '"') : '';
			$('<td ' + title + 'style="background-color:' + ((area.charAt(0) == '1') ? 'gray': 'white')+';">' + item.parent_id  + '</td>').appendTo(row);  // name
			$('<td>' + person_cell  + '</td>').appendTo(row);  // name
			// $('<td>' + item.be.substr(0, 15)  + '</td>').appendTo(row);  // topic
			var topic = (item.be == 'NOTOPIC'? '<i>(няма тэмы альбо ўдзел без дакладу)</i>' : item.be);
			$('<td>' + topic  + '</td>').appendTo(row);  // topic
			row.appendTo(table);
			// console.log(item.here_name);
			// console.log(item.person_id);
		}
		// console.log(item.person_id);
	}
	function add_row (item, table, cid){
		if (item.country_id == cid){
			var row =$('<tr></tr>');
			$('<td>' + item.aname + ' <b>' + item.bname + '</b></td>').appendTo(row); 
			row.appendTo(table);
			// console.log(item.here_name);
		}
	}
	function show_list(data){
	var linksgrid = $('#myTable');
		linksgrid.children().remove();
		$('<thead id=myTableHead></thead>').appendTo(linksgrid); 
		var mth = $('#myTableHead');
		$('<tr id=headrow></tr>').appendTo(mth); 
		var headrow = $('#headrow');
		$('<th width=10>Дзень</th>').appendTo(headrow); 
		$('<th width=20>Час</th>').appendTo(headrow); 
		$('<th width=30>Месца</th>').appendTo(headrow); 
		$('<th width=30>Код</th>').appendTo(headrow); 
		$('<th width=100>Імя</th>').appendTo(headrow); 
		$('<th width=200>Тэма</th>').appendTo(headrow); 
		$('<tbody id=tableBody>qw</tbody>').appendTo(linksgrid); 
		var tableBody = $('#tableBody');
		// console.log('!');
		// console.log('!');
		var some = '';
		// topics_array = topics_array.sort(function(a, b) {
					 // if (a.event_date > b.event_date) { return -1 };
					 // if (a.event_date < b.event_date) { return 1 };
					 // return 0;
				// });
		jQuery.each(data, function() { add_def_row(this, tableBody, some); });
		linksgrid.tablesorter({ 
			// widthFixed: true, widgets: ['zebra'],
			headers: { // pass the headers argument and assing a object 
				// assign the secound column (we start counting zero) 
				1:{sorter: false},  // disable it by setting the property sorter to false 
				2:{sorter: false},
				3:{sorter: false},
				4:{sorter: false},
				5:{sorter: false},
			 }
		}); 
	}
	$.when(
	  $.getJSON("/json/persons.json", function(data) { person_array = data; }),
	  $.getJSON("/json/schedule.json", function(data) { schedule_array = data; }),
	  $.getJSON("/json/countries.json", function(data) { countries_json_array = data; }),
	  $.getJSON("/json/topics.json", function(data) { topics_array = data; }),
	  $.getJSON("/json/topics2.json", function(data) { topics2_array = data; })
	).then(function() {
		$("#stacksel").select2({
		   placeholder: "Імя",
			 width: 'resolve',
			data:{ results: person_array, text: 'here_name' },
			formatSelection: format,
			formatResult: format,
			 // initSelection : function (element, callback) {
				// var data = {id: element.val(), text: element.val()};
				// callback(data);
				// // alert (data);
			// },	
		});
		$("#cnsel").select2({
		   placeholder: "Краіна",
			 width: 'resolve',
			data:{ results: countries_json_array, text: 'be' },
			formatSelection: format2,
			formatResult: format2,
			// initSelection : function (element, callback) {
				// var data = {id: element.val(), text: element.val()};
				// callback(data);
			// },	
		});
		$("#myTable").tablesorter('font-family: Georgia'); 
		$("#stacksel").on("change select2-highlight select2-selecting", function() {
			// var cid = $(this).val();
			var sel = $(this).select2('data');
			// console.log(sel);
			// console.log(JSON.stringify(sel));
			if (sel.length !== 0){
				// [23:09:13.182] "{"country":"Бельгія","bname":"Alaverdian","country_id":19,"id":2,"code":"be","aname":"K.","here_name":"Alaverdian K."}"
				// console.log(JSON.stringify($("#stacksel").select2('data')));
				// console.log(JSON.stringify($(this).select2('data')));
				// person_info(cid);
				person_popup(sel.id, sel.aname + ' ' + sel.bname, sel.country, sel.country_id);
			}
		});
		$("#cnsel").on("change", function() {
			var cid = $(this).val();
			// alert($cid);
				var linksgrid = $('#myTable');
				linksgrid.children().remove();
				$('<thead id=myTableHead></thead>').appendTo(linksgrid); 
				var mth = $('#myTableHead');
				$('<tr id=headrow></tr>').appendTo(mth); 
					var headrow = $('#headrow');
					$('<th width=100>Імя</th>').appendTo(headrow); 
				$('<tbody id=tableBody>qw</tbody>').appendTo(linksgrid); 
				var tableBody = $('#tableBody');
				// console.log('!');
				// console.log('!');
				jQuery.each(person_array, function() { add_row(this, tableBody, cid); });
		});
		var pathname = window.location.pathname;
		(pathname == '/smart') ? show_list(topics2_array) : show_list(topics_array);
		// alert (pathname);
		$( "#paperslist" ).click(function() {
		  show_list(topics_array);
		});
		$( "#paperslist2" ).click(function() {
		  show_list(topics2_array);
		});
		$("#myTable").on("click", 'a.person', function(event){
		// $( ".person" ).click(function() {
		  // alert($(this).attr('id'));
		   // person_info(115);
			var name = $(this).text();
			var cur_num=$(this).attr('id').split('-')[1]; 
			// console.log(cur_num);
			person_popup(cur_num, name);
		});	
		$("body").on("click", '#signup', function(event){
			event.preventDefault();
			$('#signup').hide();
		});	
		 $('.modal_close').click(function (e) {
			//Cancel the link behavior
			e.preventDefault();
			$('#signup').hide();
		});  
	});
});