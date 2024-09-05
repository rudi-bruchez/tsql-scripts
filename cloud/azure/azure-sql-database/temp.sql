

select g.state_description, g.row_group_id, s.column_id
    ,s.row_count, s.min_data_id, s.max_data_id, g.deleted_rows
from
    sys.column_store_segments s join sys.partitions p on
        s.partition_id = p.partition_id
    join sys.column_store_row_groups g on
        p.object_id = g.object_id and
        s.segment_id = g.row_group_id
where
    p.object_id = object_id(N'dbo.CCI')
order by
    g.row_group_id, s.column_id;