# Copyright © 2011 MUSC Foundation for Research Development
# All rights reserved.

# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following
# disclaimer in the documentation and/or other materials provided with the distribution.

# 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products
# derived from this software without specific prior written permission.

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING,
# BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT
# SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR
# TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

$(document).ready ->
  display_dependencies=
    "#study_funding_status" :
      pending_funding    : ['.pending_funding']
      funded             : ['.funded']
    "#study_potential_funding_source" :
      internal           : ['.internal_potential_funded_pilot_project']
    "#study_funding_source" :
      federal            : ['.federal']
      internal           : ['.internal_funded_pilot_project']
    '#study_research_types_info_attributes_human_subjects' :
      'true'             : ['.nct_number', '.hr_number', '.pro_number', '.irb_of_record', '.submission_type',
                            '.irb_approval_date', '.irb_expiration_date', '.approval_pending',
                            '.study_phase']
    '#study_research_types_info_attributes_vertebrate_animals' :
      'true'             : ['.iacuc_number', '.name_of_iacuc', '.iacuc_approval_date',
                            '.iacuc_expiration_date']
    '#study_research_types_info_attributes_investigational_products' :
      'true'             : ['.ind_number', '.ide_number']
    '#study_research_types_info_attributes_ip_patents':
      'true'             : ['.patent_number', '.inventors']
    '#study_investigational_products_info_attributes_ind_number':
      'true'             : ['.ind_on_hold']
    '#study_impact_areas_attributes_6__destroy':
      'true'             : ['.impact_other']
    

  FormFxManager.registerListeners($('.edit-project-view'), display_dependencies)


  $(".study_type .field").hide();

  study_type_form = $('.study_type')
  study_selected_for_epic_radio = $('input[name=\'study[selected_for_epic]\']')
  certificate_of_confidence_dropdown = $('#study_type_answer_certificate_of_conf_answer')
  higher_level_of_privacy_dropdown = $('#study_type_answer_higher_level_of_privacy_answer')
  access_required_dropdown = $('#study_type_answer_access_study_info_answer')
  epic_inbasket_dropdown = $('#study_type_answer_epic_inbasket_answer')
  research_active_dropdown = $('#study_type_answer_research_active_answer')
  restrict_sending_dropdown = $('#study_type_answer_restrict_sending_answer')

  $.prototype.hide_elt = () ->
    this[0].selectedIndex = 0
    this.closest('.field').hide()
    return this

  $.prototype.show_elt = () ->
    this.closest('.field').show()
    return this

  show_if_value_selected = (dropdown) ->
    if $('#study_study_type_question_group_id').val() == "inactive" && $('input[name=\'study[selected_for_epic]\']:checked').val() == 'true'
      study_type_form.show()
      certificate_of_confidence_dropdown.show_elt()
      higher_level_of_privacy_dropdown.show_elt()
    else if $('#study_study_type_question_group_id').val() == "active"
      if dropdown[0].selectedIndex > 0
        dropdown.show_elt()
      else
        dropdown.hide_elt()

  #FOR EDITING A STUDY - EPIC BOX
  # Since the 'ready' function only gets fired when editing,
  # we can assume here that there are values being loaded in
  # each of the dropdowns. Since we can also assume that the
  # logic governing those dropdowns was operating under the
  # same set of rules when the study was first saved, as it
  # is now, we can just display the fields that have a value
  # selected and hide those that do not because the study had
  # to be in a valid state for the initial save to succeed in
  # the first place.

  show_if_value_selected(certificate_of_confidence_dropdown)
  show_if_value_selected(higher_level_of_privacy_dropdown)
  show_if_value_selected(access_required_dropdown)
  show_if_value_selected(epic_inbasket_dropdown)
  show_if_value_selected(research_active_dropdown)
  show_if_value_selected(restrict_sending_dropdown)

  #FOR EDITING A STUDY - EPIC BOX
  # When a user is editing the epic box information, and does not select
  # an answer and that unselected answer hits the validations, the above 
  # code will hide the unselected field.
  # This code is for preventing that from happening:
  # We are using localStorage to save the array of values we have selected
  # before hitting validations and then comparing those to the original values
  # if there is a discrepancy between them we show/hide 
  # dropdowns depending on the logic associated with that particular dropdown

  before_hitting_validations_array = new Array()
  errors = new Array()

  study_no_errors = localStorage.getItem("study_no_errors")  

  # Saving array of study_type_answers before and after hitting validation
  if $('.field_with_errors label').text() == "Study type questions"
    $('.study_type .field select').each -> 
      errors.push $(this).val()
  else
    $('.study_type .field select').each -> 
      before_hitting_validations_array.push $(this).val()
    
    localStorage.setItem('study_no_errors', before_hitting_validations_array)

  study_no_errors = JSON.stringify(study_no_errors)
  study_no_errors = JSON.parse(study_no_errors).split(',')

  not_selected = new Array()
  show_index = new Array()
  
  # Comparing before/after hitting validation study type answer arrays
  # Showing/hiding based on appropriate epic logic
  if errors
    for i in [0...errors.length]
      if study_no_errors[i] != errors[i]
        if errors[i] == ""
          not_selected.push errors[i]
          show_index.push i 
    for i in show_index
      switch i
        when 0 then certificate_of_confidence_dropdown.show_elt() 
        when 1 then higher_level_of_privacy_dropdown.show_elt() 
        when 2 then access_required_dropdown.show_elt()
        when 3 then epic_inbasket_dropdown.show_elt()
        when 4 then research_active_dropdown.show_elt()
        when 5 then restrict_sending_dropdown.show_elt() 
    if errors[0] == 'false' && errors[1] == 'true'
      access_required_dropdown.show_elt()
    else if errors[0] == 'true' 
      access_required_dropdown.hide_elt()
      epic_inbasket_dropdown.hide_elt()
      research_active_dropdown.hide_elt()
      restrict_sending_dropdown.hide_elt() 
    else if errors[0] == 'false' && errors[1] == 'false'
      access_required_dropdown.hide_elt()
  else
    #do nothing

  # Logic for epic info box 
  study_selected_for_epic_radio.on 'change', (e) ->
    if $('input[name=\'study[selected_for_epic]\']:checked').val() == 'true'
      study_type_form.show()
      certificate_of_confidence_dropdown.show_elt()
      higher_level_of_privacy_dropdown.show_elt()
    else
      study_type_form.hide()
      certificate_of_confidence_dropdown.hide_elt()
      higher_level_of_privacy_dropdown.hide_elt().trigger 'change'
    return

  certificate_of_confidence_dropdown.on 'change', (e) ->
    new_value = $(e.target).val()
    higher_level_of_privacy_value = higher_level_of_privacy_dropdown.val()
    if new_value == 'false'
      if higher_level_of_privacy_value == 'false'
        access_required_dropdown.hide_elt()
        epic_inbasket_dropdown.show_elt()
        research_active_dropdown.show_elt()
        restrict_sending_dropdown.show_elt()
      else if higher_level_of_privacy_value == 'true'
        access_required_dropdown.show_elt()
        epic_inbasket_dropdown.hide_elt()
        research_active_dropdown.hide_elt()
        restrict_sending_dropdown.hide_elt()
      else
        access_required_dropdown.hide_elt()
        epic_inbasket_dropdown.hide_elt()
        research_active_dropdown.hide_elt()
        restrict_sending_dropdown.hide_elt()
    else
      access_required_dropdown.hide_elt()
      epic_inbasket_dropdown.hide_elt()
      research_active_dropdown.hide_elt()
      restrict_sending_dropdown.hide_elt()
    return

  higher_level_of_privacy_dropdown.on 'change', (e) ->
    new_value = $(e.target).val()
    certificate_of_confidence_value = certificate_of_confidence_dropdown.val()
    if certificate_of_confidence_value == 'false'
      if new_value == 'false'
        access_required_dropdown.hide_elt()
        epic_inbasket_dropdown.show_elt()
        research_active_dropdown.show_elt()
        restrict_sending_dropdown.show_elt()
      else if new_value == 'true'
        access_required_dropdown.show_elt()
        epic_inbasket_dropdown.hide_elt()
        research_active_dropdown.hide_elt()
        restrict_sending_dropdown.hide_elt()
      else
        access_required_dropdown.hide_elt()
        epic_inbasket_dropdown.hide_elt()
        research_active_dropdown.hide_elt()
        restrict_sending_dropdown.hide_elt()
    else if new_value == ''
      access_required_dropdown.hide_elt()
      epic_inbasket_dropdown.hide_elt()
      research_active_dropdown.hide_elt()
      restrict_sending_dropdown.hide_elt()
    return
 
  access_required_dropdown.on 'change', (e) ->
    new_value = $(e.target).val()

    if new_value == 'false'
      epic_inbasket_dropdown.show_elt()
      research_active_dropdown.show_elt()
      restrict_sending_dropdown.show_elt()
    else
      epic_inbasket_dropdown.hide_elt()
      research_active_dropdown.hide_elt()
      restrict_sending_dropdown.hide_elt()


  ######## End of send to epic study question logic ##############

  $('#study_funding_status').change ->
    $('#study_funding_source').val("")
    $('#study_potential_funding_source').val("")
    $('#study_funding_source').change()
    $('#study_potential_funding_source').change()
    $('#study_indirect_cost_rate').val("")

  $('#study_research_types_info_attributes_investigational_products').change ->
    if !$(this).is(':checked')
      $('#study_investigational_products_info_attributes_ind_number').val('')
      $('#study_investigational_products_info_attributes_ind_number').change()
      $('#study_investigational_products_info_attributes_ind_on_hold').attr('checked', false)

  $('#study_federal_phs_sponsor').change ->
    $('#study_federal_non_phs_sponsor').val("")

  $('#study_federal_non_phs_sponsor').change ->
    $('#study_federal_phs_sponsor').val("")

  $('#study_funding_source, #study_potential_funding_source').change ->
    switch $(this).val()
      when "internal", "college" then $('#study_indirect_cost_rate').val(I18n["indirect_cost_rates"]["internal_and_college"])
      when "industry" then $('#study_indirect_cost_rate').val(I18n["indirect_cost_rates"]["industry"])
      when "foundation", "investigator" then $('#study_indirect_cost_rate').val(I18n["indirect_cost_rates"]["foundation_and_investigator"])
      when "federal" then $('#study_indirect_cost_rate').val(I18n["indirect_cost_rates"]["federal"])



  # id       - where to stick datepicker
  # altField - input element(s) that is to be updated with
  #            the selected date from the datepicker
  setupDatePicker = (id, altField) ->
    $(id).datepicker(
      changeMonth: true,
      changeYear:true,
      constrainInput: true,
      dateFormat: "m/dd/yy",
      showButtonPanel: true,
      closeText: "Clear",
      altField: altField,
      altFormat: 'yy-mm-dd',

      beforeShow: (input)->
        callback = ->
          buttonPane = $(input).datepicker("widget").find(".ui-datepicker-buttonpane")
          buttonPane.find('button.ui-datepicker-current').hide()
          buttonPane.find('button.ui-datepicker-close').on 'click', ->
            $.datepicker._clearDate(input)
        setTimeout( callback, 1)
    ).addClass('date')

  setupDatePicker('#funding_start_date', '#study_funding_start_date')
  $('#funding_start_date').attr("readOnly", true)

  setupDatePicker('#potential_funding_start_date', '#study_potential_funding_start_date')
  $('#potential_funding_start_date').attr("readOnly", true)

  setupDatePicker('#irb_approval_date', '#study_human_subjects_info_attributes_irb_approval_date')
  $('#irb_approval_date').attr("readOnly", true)

  setupDatePicker('#irb_expiration_date', '#study_human_subjects_info_attributes_irb_expiration_date')
  $('#irb_expiration_date').attr("readOnly", true)

  setupDatePicker('#iacuc_approval_date', '#study_vertebrate_animals_info_attributes_iacuc_approval_date')
  $('#iacuc_approval_date').attr("readOnly", true)

  setupDatePicker('#iacuc_expiration_date', '#study_vertebrate_animals_info_attributes_iacuc_expiration_date')
  $('#iacuc_expiration_date').attr("readOnly", true)

  #This is to disabled the submit after you click once, so you cant fire multiple posts at once.
  $("form").submit ->
    unless $('#study_research_types_info_attributes_human_subjects').is(':checked')
      $('#study_human_subjects_info_attributes_nct_number').val('')
    $('a.continue_button').unbind('click');

