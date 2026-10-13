"""Create the review workspace described by Prompt 3/00_CHUNG.md."""

from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
CHARACTERS = "traveler_male traveler_female mira kiri garren nyx ignar marisol raiko zephyra vesper sylvaine orrin celestine quill aldric rook fenna kestrel vael wisp selka ember neris pip echo".split()
ENEMIES = "warp_sprout wandering_shade rusted_knight void_archer warped_mage ink_rat venom_bee mirror_shade flying_book furnace_arm devourer_clone shattered_knight warp_matrix mute_librarian library_warden vault_behemoth warped_core soul_devourer".split()
STAGES = "1_concept 2_sketch 4_rig2d 5_render/preview 6_vfx".split()


def main():
    (ROOT / ".gdignore").touch(exist_ok=True)
    for family, ids in (("nhan_vat", CHARACTERS), ("quai", ENEMIES)):
        for ident in ids:
            for stage in STAGES:
                (ROOT / family / ident / stage).mkdir(parents=True, exist_ok=True)
    review = ROOT / "REVIEW.md"
    if not review.exists():
        review.write_text(
            "# Duyệt thiết kế\n\n"
            "Mở ảnh hoặc GIF ở cột xem. Đổi `chờ duyệt` thành `duyệt`, `sửa` hoặc `bỏ` và ghi góp ý. "
            "Chỉ bạn đặt trạng thái này; AI không tự duyệt. Có thể vẽ lên lớp `your_sketch` trong file Krita.\n\n"
            "| Id | Bước | Bản | Ảnh/GIF xem | Trạng thái | Ghi chú của bạn |\n"
            "| --- | --- | --- | --- | --- | --- |\n",
            encoding="utf-8",
        )
    print(f"Workspace: {ROOT}; {len(CHARACTERS)} characters; {len(ENEMIES)} enemy families")


if __name__ == "__main__":
    main()
