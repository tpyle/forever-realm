#!/usr/bin/env python3
"""Minimal WDC5 (.db2) reader: yields (id, [field values]) with arrays as lists and strings decoded.

Only what the Classic 1.60 client files need: inline-free strings (offsets into the string block), the id list,
the copy table, the relationship map (a parent ID such as SpellXSpellVisual.SpellID, read as the last field), the
storage types None / Bitpacked / CommonData / BitpackedIndexed / BitpackedIndexedArray / BitpackedSigned, and files with an offset map (variable sized records, strings inline). Field types come from the core's
DB2Metadata.h (`meta` below): ("int"|"float"|"string"|"short"|"byte", array size, signed).
"""
import struct


def read(path, meta):
    data = open(path, "rb").read()
    if data[:4] != b"WDC5":
        raise ValueError(f"{path}: not WDC5")
    (record_count, field_count, record_size, string_table_size, table_hash, layout_hash, min_id, max_id, locale,
     flags, id_index, total_field_count, bitpacked_offset, lookup_columns, storage_info_size, common_size, pallet_size,
     section_count) = struct.unpack_from("<9I2H7I", data, 136)
    pos = 136 + struct.calcsize("<9I2H7I")
    sections = []
    for _ in range(section_count):
        sections.append(struct.unpack_from("<Q8I", data, pos))
        pos += struct.calcsize("<Q8I")
    pos += field_count * 4                               # field_structure: int16 size, uint16 offset
    storage = []
    for _ in range(storage_info_size // 24):
        storage.append(struct.unpack_from("<2H5I", data, pos))
        pos += 24
    pallet_start = pos
    common_start = pallet_start + pallet_size

    # per field: pallet block offset and common data dict
    pallet_offsets, common, p, c = [], [], pallet_start, common_start
    for (_, _, additional, kind, v1, v2, v3) in storage:
        pallet_offsets.append(p)
        if kind in (3, 4):
            p += additional
        values = {}
        if kind == 2:
            for k in range(additional // 8):
                rid, val = struct.unpack_from("<I4s", data, c + k * 8)
                values[rid] = val
            c += additional
        common.append(values)

    # a parent field kept in the relationship map (e.g. SpellXSpellVisual.SpellID) is the metadata's last field, not in the records
    relationship = len(meta) == field_count + 1
    if relationship:
        meta = meta[:-1]
    if len(meta) != field_count:
        raise ValueError(f"{path}: {field_count} fields in the file, {len(meta)} in the metadata")

    def bits(record, offset, size):
        value = int.from_bytes(record[offset // 8:(offset + size + 7) // 8 + 1], "little") >> (offset % 8)
        return value & ((1 << size) - 1)

    def convert(raw4, ftype, signed):
        if ftype == "float":
            return struct.unpack("<f", raw4)[0]
        value = struct.unpack("<I", raw4)[0]
        width = {"int": 32, "string": 32, "short": 16, "byte": 8}[ftype]
        value &= (1 << width) - 1
        if signed and value >> (width - 1):
            value -= 1 << width
        return value

    rows = {}
    if flags & 1:
        for (tact, offset, count, strings_size, records_end, id_list_size, relationship_size, map_count, copy_count) in sections:
            pos = records_end
            ids = struct.unpack_from(f"<{id_list_size // 4}I", data, pos)
            pos += id_list_size
            copies = [struct.unpack_from("<2I", data, pos + k * 8) for k in range(copy_count)]
            pos += copy_count * 8
            entries = [struct.unpack_from("<IH", data, pos + k * 6) for k in range(map_count)]
            pos += map_count * 6 + relationship_size
            map_ids = struct.unpack_from(f"<{map_count}I", data, pos)
            for k, (rec_off, size) in enumerate(entries):
                if not size:
                    continue
                rid = map_ids[k] if map_count else ids[k]
                p, values = rec_off, []
                for (ftype, arr, signed) in meta:
                    out = []
                    for _ in range(arr):
                        if ftype == "string":
                            text = read_string(data, p)
                            p += len(data[p:data.index(b"\0", p)]) + 1
                            out.append(text)
                        else:
                            width = {"int": 4, "float": 4, "short": 2, "byte": 1}[ftype]
                            out.append(convert(data[p:p + width] + b"\0" * (4 - width), ftype, signed))
                            p += width
                    values.append(out if arr > 1 else out[0])
                if not 0 <= rec_off + size - p < 4:          # records are padded to 4 bytes
                    raise ValueError(f"{path}: record {rid} read {p - rec_off} of {size} bytes")
                rows[rid] = values
            for new_id, old_id in copies:
                if old_id in rows:
                    rows[new_id] = list(rows[old_id])
        return rows, layout_hash

    for (tact, offset, count, strings_size, _, id_list_size, relationship_size, _, copy_count) in sections:
        records_start = offset
        string_start = records_start + count * record_size
        ids_start = string_start + strings_size
        ids = struct.unpack_from(f"<{count}I", data, ids_start) if id_list_size else None
        copy_start = ids_start + id_list_size
        parents = {}
        if relationship and relationship_size:
            rel_start = copy_start + copy_count * 8
            entries = struct.unpack_from("<I", data, rel_start)[0]
            for k in range(entries):
                foreign_id, index = struct.unpack_from("<2I", data, rel_start + 12 + k * 8)
                parents[index] = foreign_id
        for r in range(count):
            rec_off = records_start + r * record_size
            record = data[rec_off:rec_off + record_size] + b"\0" * 8
            rid = ids[r] if ids else None
            values = []
            for f, (ftype, arr, signed) in enumerate(meta):
                bit_off, bit_size, additional, kind, v1, v2, v3 = storage[f]
                out = []
                if kind == 0:                                     # None: plain, arrays contiguous
                    step = bit_size // arr
                    for a in range(arr):
                        raw = bits(record, bit_off + a * step, step).to_bytes(4, "little")
                        if ftype == "string":
                            field_pos = rec_off + (bit_off + a * step) // 8
                            raw_val = struct.unpack("<I", raw)[0]
                            out.append(read_string(data, field_pos + raw_val) if raw_val else "")
                        else:
                            out.append(convert(raw, ftype, signed))
                elif kind in (1, 5):                              # Bitpacked (5: signed)
                    raw = bits(record, bit_off, v2)
                    if kind == 5 and raw >> (v2 - 1):
                        raw -= 1 << v2
                    out.append(convert((raw & 0xFFFFFFFF).to_bytes(4, "little"), ftype, signed))
                elif kind == 2:                                   # CommonData: default v1
                    raw = common[f].get(rid, v1.to_bytes(4, "little"))
                    out.append(convert(raw, ftype, signed))
                elif kind == 3:                                   # BitpackedIndexed: pallet entry
                    idx = bits(record, bit_off, v2)
                    raw = data[pallet_offsets[f] + idx * 4:pallet_offsets[f] + idx * 4 + 4]
                    out.append(convert(raw, ftype, signed))
                elif kind == 4:                                   # BitpackedIndexedArray: v3 values per index
                    idx = bits(record, bit_off, v2)
                    for a in range(v3):
                        o = pallet_offsets[f] + (idx * v3 + a) * 4
                        out.append(convert(data[o:o + 4], ftype, signed))
                else:
                    raise ValueError(f"{path}: storage type {kind}")
                values.append(out if arr > 1 else out[0])
            if rid is None:
                rid = values[id_index]
            if relationship:
                values.append(parents.get(r, 0))
            rows[rid] = values
        for k in range(copy_count):
            new_id, old_id = struct.unpack_from("<2I", data, copy_start + k * 8)
            if old_id in rows:
                rows[new_id] = list(rows[old_id])
    return rows, layout_hash


def read_string(data, pos):
    end = data.index(b"\0", pos)
    return data[pos:end].decode("utf-8", "replace")
