#
#
# == License:
# Fairnopoly - Fairnopoly is an open-source online marketplace.
# Copyright (C) 2013 Fairnopoly eG
#
# This file is part of Fairnopoly.
#
# Fairnopoly is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# Fairnopoly is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with Fairnopoly.  If not, see <http://www.gnu.org/licenses/>.
#
class ReAddSlugIndex < ActiveRecord::Migration
  class Article < ActiveRecord::Base
  end

  def up
    Article.reset_column_information
    doubled_articles = Article.select(:slug).group(:slug).having("count(*) > 1")
    doubled_articles.each do |article|
       if article.slug
        while Article.where(:slug => article.slug).size != 0 do
           article.slug = "_" + article.slug
         end
       end

      article.save!
    end
    add_index :articles, :slug, unique: true unless index_exists? :articles, :slug, unique: true
  end

  def down
    #not really needed
  end
end
