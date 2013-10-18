class Appointment < ActiveRecord::Base
  audited

  belongs_to :calendar
  belongs_to :visit_group
  has_many :procedures, :dependent => :destroy
  has_many :visits, :through => :procedures
  has_many :notes
  has_many :appointment_completions, :dependent => :destroy
  attr_accessible :visit_group_id
  attr_accessible :organization_id
  attr_accessible :completed_at
  attr_accessible :position
  attr_accessible :name

  attr_accessible :procedures_attributes
  attr_accessible :appointment_completions_attributes

  accepts_nested_attributes_for :procedures
  accepts_nested_attributes_for :appointment_completions

  after_create :create_appointment_completions


  def populate_procedures(visits)
    visits.each do |visit|
      line_item = visit.line_items_visit.line_item
      if line_item.service.is_ctrc?
        procedure = self.procedures.build(:line_item_id => line_item.id, :visit_id => visit.id, :toasts_generated => true)
        procedure.save
      end
    end
  end

  def position_switch
    self.visit_group ? self.visit_group.position : self.position
  end

  def name_switch
    self.visit_group ? self.visit_group.name : self.name
  end

  def completed?
    self.appointment_completions.each do |x|
      return true if x.completed_date?
    end
    return false
  end
  
  # TODO
  # Update this method when the new core specific completed dates are added
  def completed_for_core? (core_id)
    if self.completed_at(core_id).first.try(:completed_date)
      return true
    else
      return false
    end
  end

  def completed_at (core_id)
    AppointmentCompletion.where("organization_id = ? AND appointment_id = ?", core_id, self.id)
  end

  def create_appointment_completions
    cores = []
    cores = Organization.where(show_in_cwf: true)

    cores.each do |core|
      if self.appointment_completions.where(:organization_id => core.id).empty?
        self.appointment_completions.create(:organization_id => core.id) 
      end
    end
  end

  def display_name
    self.name.nil? ? self.visit_group.name : self.name
  end
  
  ### audit reporting methods ###
    
  def audit_excluded_actions
    ['create']
  end

  ### end audit reporting methods ###

end
