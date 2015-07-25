#!/usr/bin/env ruby

# file: mymedia-card.rb

require 'mymedia-kvx'


class MyMediaCard < MyMediaKvx

  attr_reader :txt_filepath
  
  def initialize(opt={}, public_type: 'kvx', media_type: public_type, 
                                                     config: nil, ext: 'txt')
    
    super(media_type: media_type, public_type: public_type, 
                                                    config: config, ext: ext)    
    @prefix = 'meta'
    @txt_filepath = File.join(@media_src, \
                              Time.now.strftime('meta%d%m%yT%H%M') + '.txt' )    
    
  end

  def create_metadata_file(static_file: false)

    raise "MyMediaCard: ext: must be supplied at initialize()" unless @ext
    
    path = static_file ? File.join(@media_src, 'raw') : @media_src
    
    dir = DirToXML.new(path)
    raw_s = dir.select_by_ext(@ext).sort_by_lastmodified.last[:name]
    
    s,ext = raw_s.split(/(?=\.\w+$)/)
    ext = '' if ext == '.dir'
    raw_name, raw_tags = s.split(/--/,2)
    tags = raw_tags ? raw_tags.split(/--/) : []
    desc = raw_name.gsub(/-/,' ')
    desc.capitalize! unless desc[0] == desc[0].upcase

    static_path = if static_file then

      @txt_filepath = File.join(@media_src, raw_name.downcase + '.txt' )
      filename = raw_name.downcase + ext
      "%s/raw/%s" % [@public_type, filename]
      
    else
      
      filename = raw_name.downcase + ext

      "%s/%s/%s" % [@public_type, \
        Time.now.strftime('%Y/%b/%d').downcase, filename]
      
    end
    
    raw_static_destination = "/r/%s" % [static_path]
    
    summary = {title: desc, tags: tags.join(' ')}
    body = {file: raw_static_destination}    

    kvx = Kvx.new({summary: summary, body: body}, \
                                             attributes: {type: @media_type})
    Dir.chdir @media_src
    File.write @txt_filepath, kvx.to_s

    Dir.chdir 'raw' if static_file

    FileUtils.mv raw_s, filename
  end
  
  private
  
  
  def copy_edit(src_path, destination, raw='')

    kvx, raw_msg = super(src_path, destination)

    # copy the media file to the destination
    destination = kvx.body[:file]

    file = destination[/(raw\/)?[^\/]+$/]
    
    subdir = file[/.*(?=\.\w+$)|.*/]
    
    if File.exists? File.join(@media_src, subdir) then
      
      FileUtils.cp_r File.join(@media_src, subdir), File.join(@home, File.dirname(destination))
      
      if File.basename(destination) != subdir then
        FileUtils.cp File.join(@media_src, file), File.join(@home, destination)
      end
      
    else
      
      FileUtils.cp File.join(@media_src, file), File.join(@home, destination)
      
    end
    
    [kvx, raw_msg]
  end
  
end