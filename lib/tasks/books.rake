desc "This task is to update the book summaries according to new format"
task :update_book_summaries => :environment do
  template = <<-eos
    <div id="bb-container" class="bb-container">    
     
        <div class="menu-panel">
            <h3>Indice</h3>
            <ul id="menu-toc" class="menu-toc">
            </ul>
        </div>
     
        <div class="bb-custom-wrapper">
     
            <div id="bb-bookblock" class="bb-bookblock">     
            </div><!-- /bb-bookblock -->
             
            <nav>
                <span id="bb-nav-prev" href="#">&larr;</span>
                <span id="bb-nav-next" href="#">&rarr;</span>
            </nav>
     
            <span id="tblcontents" class="menu-button">Indice</span>
            <a class="home-button" href="/library">Home</a>
     
        </div><!-- /bb-custom-wrapper -->
     
    </div><!-- /container -->
  eos

  Book.all.each do |book|
    structure = Nokogiri::HTML(template)
    doc = Nokogiri::HTML.parse book.summary
    item = 1
    menu = structure.xpath('//body/div/div[@class="menu-panel"]/ul').first
    content = structure.xpath('//body/div/div[@class="bb-custom-wrapper"]/div').first
    
    bb_item = nil
    div_content = nil
    scroller = nil

    doc.xpath('//body/*').each do |node|
      if node.name == 'h3' && node.text.presence
        unless scroller.nil? && div_content.nil? && bb_item.nil?
          div_content.add_child(scroller)
          bb_item.add_child(div_content)
          content.add_child(bb_item)
        end

        bb_item = Nokogiri::XML::Node.new('div', structure)
        bb_item['class'] = 'bb-item'
        bb_item['id'] = "item#{item}"

        div_content = Nokogiri::XML::Node.new('div', structure)
        div_content['class'] = 'content'

        scroller = Nokogiri::XML::Node.new('div', structure)
        scroller['class'] = 'scroller'
        

        li = Nokogiri::XML::Node.new('li', structure)
        li['class'] = 'menu-toc-current' if item == 1

        anchor = Nokogiri::XML::Node.new('a', structure)
        anchor['href'] = "#item#{item}"
        anchor.content = node.text.strip

        li.add_child(anchor)
        menu.add_child(li)
        item += 1
      end

      scroller.add_child(node) unless scroller.nil?
    end

    book.update_attribute(:summary, structure.inner_html)
  end
end

task :generate_slugs => :environment do
  Book.find_each(&:save)
end