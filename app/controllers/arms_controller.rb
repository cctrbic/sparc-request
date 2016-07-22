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

class ArmsController < ApplicationController
  respond_to :html, :js, :json

  before_filter :initialize_service_request
  before_filter :authorize_identity
  before_filter :find_arm, only: [:edit, :update, :destroy]

  def index
    service_request = ServiceRequest.find( params[:srid] )
    @arms           = service_request.arms
    @arms_editable  = service_request.arms_editable?
    @arm_count      = @arms.count
  end

  def new
    @protocol = Protocol.find( params[:protocol_id] )
    @arm      = @protocol.arms.new
  end

  def create
    arm = Arm.create( params[:arm].merge(protocol_id: params[:protocol_id]) )

    if arm.valid?
      flash[:success] = t(:arms)[:created]
    else
      @errors = arm.errors
    end
  end

  def edit
  end

  def update
    if @arm.update_attributes( params[:arm] )
      flash[:success] = t(:arms)[:updated]
    else
      @errors = @arm.errors
    end
  end

  def destroy
    @arm.destroy
    
    flash[:alert] = t(:arms)[:destroyed]
  end

  private

  def find_arm
    @arm = Arm.find( params[:id] )
  end
end