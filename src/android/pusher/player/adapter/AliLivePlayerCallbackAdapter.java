package com.aliyun.aliliveplayersdk.adapter;

import android.text.Html;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import com.zhongzilian.chestnutapp.R;

import java.util.List;

public class AliLivePlayerCallbackAdapter extends RecyclerView.Adapter<AliLivePlayerCallbackAdapter.AliLivePlayerCallbackViewHolder>{

    private final List<String> mData;

    public AliLivePlayerCallbackAdapter(List<String> data){
        this.mData = data;
    }

    @NonNull
    @Override
    public AliLivePlayerCallbackViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        View inflate = LayoutInflater.from(parent.getContext()).inflate(R.layout.layout_player_callback_item, parent, false);
        return new AliLivePlayerCallbackViewHolder(inflate);
    }

    @Override
    public void onBindViewHolder(@NonNull AliLivePlayerCallbackViewHolder holder, int position) {
        holder.mMsgTextView.setText(Html.fromHtml(mData.get(position)));
    }

    @Override
    public int getItemCount() {
        return mData == null ? 0 : mData.size();
    }

    public static class AliLivePlayerCallbackViewHolder extends RecyclerView.ViewHolder{

        private final TextView mMsgTextView;

        public AliLivePlayerCallbackViewHolder(@NonNull View itemView) {
            super(itemView);
            mMsgTextView = itemView.findViewById(R.id.tv_msg);
        }
    }
}
