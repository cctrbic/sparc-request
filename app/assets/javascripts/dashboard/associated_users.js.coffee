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

# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
$(document).ready ->

  $(document).on 'click', '#new-associated-user-button', ->
    if $(this).data('permission')
      $.ajax
        type: 'get'
        url: '/dashboard/associated_users/new.js'
        data:
          protocol_id: $(this).data('protocol-id')
    else
      $('.permissions-dialog').dialog('open')
      $('.permissions-dialog .text').html('Edit.')


  $(document).on 'click', '.edit-associated-user-button', (event) ->
    if $(this).data('permission')
      project_role_id = $(this).data('project-role-id')
      $.ajax
        type: 'get'
        url: "/dashboard/associated_users/#{project_role_id}/edit.js"
    else
      $('.permissions-dialog').dialog('open')
      $('.permissions-dialog .text').html('Edit.')


  $(document).on 'click', '.delete-associated-user-button', ->
    if $(this).data('permission')
      project_role_id        = $(this).data('project-role-id')
      current_user_id        = parseInt($('#current_user_id').val(), 10)
      pr_identity_role       = $(this).data('identity-role')
      pr_identity_id         = $(this).data('identity-id')

      if current_user_id == pr_identity_id
        confirm_message = 'This action will remove you from the project. Are you sure?'
      else
        confirm_message = 'Are you sure you want to remove this user?'

      if pr_identity_role == 'primary-pi'
        alert I18n['protocol_information']['require_primary_pi_message']
      else
        if confirm(confirm_message)
          $.ajax
            type: 'delete'
            url: "/dashboard/associated_users/#{project_role_id}"

    else
      $('.permissions-dialog').dialog('open')
      $('.permissions-dialog .text').html('Edit.')

  #**************** Add Authorized User Form Begin ****************

  $(document).on 'change', '#project_role_identity_credentials', ->
    # Credentials - Dropdown
    $('.credentials_dependent').hide()
    switch $(this).val()
      when 'other' then $('.credentials_dependent.other').show()

  $(document).on 'change', '#project_role_role', ->
    # Role - Dropdown
    $('.role_dependent').hide()
    switch $(this).val()
      when 'other'
        $('#project_role_role_other').show()
      when 'business-grants-manager'
        $('#project_role_project_rights_none').attr('disabled', true)
        $('#project_role_project_rights_view').attr('disabled', true)
        $('#project_role_project_rights_request').attr('disabled', true)
        $('#project_role_project_rights_approve').attr('checked', true)
      when 'pi', 'primary-pi'
        $('#project_role_project_rights_none').attr('disabled', true)
        $('#project_role_project_rights_view').attr('disabled', true)
        $('#project_role_project_rights_request').attr('disabled', true)
        $('#project_role_project_rights_approve').attr('checked', true)
        $('.role_dependent.commons_name').show()
        $('.role_dependent.subspecialty').show()
      when '', 'grad-research-assistant', 'undergrad-research-assistant', 'research-assistant-coordinator', 'technician', 'general-access-user'
      else
        $('input[name="project_role[project_rights]"]').attr('disabled', false).attr('checked', false)
        $('.role_dependent.commons_name').show()
        $('.role_dependent.subspecialty').show()

  #**************** Add Authorized User Form End ****************
