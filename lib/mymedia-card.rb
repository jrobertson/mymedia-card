#!/usr/bin/env ruby

# file: mymedia-card.rb

require 'mymedia'


class MyMediaCard < MyMedia::Base

  attr_reader :kvx
  
  def initialize(opt={}, public_type: 'kvx', media_type: public_type, 
                                                         config: nil, ext: nil)
    
    @public_type = public_type
    super(media_type: media_type, public_type: public_type, config: config)
    
    @media_src = "%s/media/%s" % [@home, public_type]
    @target_ext = '.xml'

    @media_type = media_type
    @ext = ext
    
  end

  def create_metadata_file

    raise "MyMediaCard: ext: must be supplied at initialize()" unless @ext
    
    dir = DirToXML.new(@media_src)
    raw_s = dir.select_by_ext(@ext).sort_by_lastmodified.last[:name]
    
    s,ext = raw_s.split(/(?=\.\w+$)/)
    raw_name, raw_tags = s.split(/--/,2)
    tags = raw_tags ? raw_tags.split(/--/) : []
    desc = raw_name.gsub(/-/,' ')
    desc.capitalize! unless desc[0] == desc[0].upcase
    filename = raw_name.downcase + ext

    static_path = "%s/%s/%s" % [@public_type, \
      Time.now.strftime('%Y/%b/%d').downcase, filename]
    
    raw_static_destination = "%s/%s/%s" % [@website, 'r',static_path]
    
    summary = {title: desc, tags: tags.join(' ')}
    body = {file: raw_static_destination}    

    kvx = Kvx.new({summary: summary, body: body}, attributes: {type: @media_type})
    meta_filename = Time.now.strftime('meta%d%m%yT%H%M') + '.txt'    
    Dir.chdir @media_src
    
    File.write meta_filename, kvx.to_s
    
    FileUtils.mv raw_s, filename
  end
  
  private
  
  def copy_publish(filename, raw_msg='')

    src_path = File.join(@media_src, filename)
    raise "file not found : " + src_path unless File.exists? src_path

    file_publish(src_path, raw_msg) do |destination, raw_destination|

      if not raw_msg or raw_msg.empty? then        
        raw_msg = File.basename(src_path) + " updated: " + Time.now.to_s
      end

      if File.extname(src_path) == '.txt' then

        kvx, raw_msg = copy_edit(src_path, destination)
        copy_edit(src_path, raw_destination)

      else

        kvx = Kvx.new(src_path)
        title = kvx.summary[:title] || ''

        kvx.summary[:original_source] = File.basename(src_path)
        
        File.write destination, kvx.to_s

      end

      if not File.basename(src_path)[/meta\d{6}T\d{4}\.txt/] then
        
        xml_filename = File.basename(src_path).sub(/txt$/,'xml')
        FileUtils.cp destination, @home + "/#{@public_type}/" + xml_filename
        
        if File.extname(src_path) == '.txt' then
          FileUtils.cp src_path, @home + "/#{public_type}/" + File.basename(src_path)
        end

        #publish the static links feed
        kvx_filepath = @home + "/#{@public_type}/static.xml"

        target_url = "%s/%s/%s" % [@website, @public_type, xml_filename]

        publish_dynarex(kvx_filepath, {title: xml_filename, url: target_url })
        
      end
      
      [raw_msg,target_url]
    end    

  end
  
  def copy_edit(src_path, destination, raw='')

    txt_destination = destination.sub(/xml$/,'txt')
    FileUtils.cp src_path, txt_destination        

    buffer = File.read(src_path)
    buffer2 = buffer.gsub(/\[[xX]\]/,'✓').gsub(/\[\s*\]/,'.')

    @kvx = Kvx.new(buffer2.strip)

    title = kvx.summary[:title]

    tags = if kvx.summary[:tags] then
      '#' + kvx.summary[:tags].split.join(' #') 
    else
      ''
    end
    
    raw_msg = ("%s %s" % [title, tags]).strip
        
    kvx.summary[:original_source] = File.basename(src_path)
    kvx.summary[:source] = File.basename(txt_destination)

    kvx.summary[:xslt] = @xsl unless kvx.item[:xslt]
    File.write destination, kvx.to_xml
    
    # copy the media file to the destination
    destination = kvx.body[:file][/^https?:\/\/[^\/]+(.*)/,1]
    file = destination[/[^\/]+$/]
    FileUtils.cp File.join(@media_src, file), File.join(@home, destination)

    [kvx, raw_msg]
  end
  
end