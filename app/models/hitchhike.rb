class Hitchhike < ActiveRecord::Base
  
  has_attached_file :photo, 
                    :styles => { :cropped => "200x100#", :large => "500x250>"}, 
                    :processors => [:cropper]
  attr_accessor :crop_x, :crop_y, :crop_w, :crop_h
  after_update :reprocess_photo, :if => :cropping?
  
  validates_presence_of :title, :from, :to
  
  # used to create custom json (http://github.com/qoobaa/to_hash)
  include ToHash
  
  def cropping?
    !crop_x.blank? && !crop_y.blank? && !crop_w.blank? && !crop_h.blank?
  end
  
  def photo_geometry(style = :original)
    @geometry ||= {}
    @geometry[style] ||= Paperclip::Geometry.from_file(photo.path(style))
  end
  
  def to_json
    hash = self.to_hash(:title, :from, :to, :id)
    hash[:photo] = {:small => self.photo.url(:cropped), :large => self.photo.url(:large)} if self.photo.file?
    JSON.pretty_generate(hash)
  end
  
  private
  
  def reprocess_photo
    photo.reprocess!
  end  
end
