import React from 'react';

interface FilterProps {
  tags: any[];
  onFilter: (tagId: string) => void;
}

const Filter: React.FC<FilterProps> = ({ tags, onFilter }) => {
  const handleFilter = (e: React.ChangeEvent<HTMLSelectElement>) => {
    onFilter(e.target.value);
  };

  return (
    <div className="input-group mb-3">
      <select className="form-select" onChange={handleFilter}>
        <option value="">Filter by tag...</option>
        {tags.map(tag => (
          <option key={tag.tag_id} value={tag.tag_name}>
            {tag.tag_name}
          </option>
        ))}
      </select>
    </div>
  );
};

export default Filter;
